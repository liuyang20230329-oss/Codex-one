const {
  getCategoryById,
  getContinueLesson,
  getLessonById,
  getRecommendedLessonsFor
} = require('../../utils/content-data');
const auth = require('../../utils/auth');
const trial = require('../../utils/trial');
const {
  COPY,
  LOGIN_SHEET_SCENARIOS,
  getLoginSheetContent
} = require('../../utils/copy');

const AUDIO_DOWNLOAD_TIMEOUT = 180000;
const LOCAL_AUDIO_PROBE_TIMEOUT = 3000;
const FAVORITES_KEY_PREFIX = 'lyc_favorites_';
const TRIAL_CONFIG = trial.getTrialConfig();

function getDefaultPlayButtonText(lesson) {
  if (!lesson) {
    return '开始播放';
  }

  if (lesson.audioUrl) {
    return '播放音频';
  }

  if (lesson.sourcePath) {
    return '播放本地音频';
  }

  return '开始播放';
}

function buildAudioDebug(extra) {
  return Object.assign(
    {
      status: '未初始化',
      source: '',
      lastError: '',
      lastEvent: '',
      currentTime: '0.0s'
    },
    extra || {}
  );
}

Page({
  data: {
    lesson: null,
    category: null,
    recommendationList: [],
    activeSegmentIndex: 0,
    isPlaying: false,
    isFollowReading: false,
    isCollected: false,
    isGuestMode: true,
    isTrialMode: false,
    trialCount: 0,
    trialMaxCount: TRIAL_CONFIG.maxCountPerDay,
    trialMaxSeconds: TRIAL_CONFIG.maxSeconds,
    showTrialBanner: false,
    showLoginSheet: false,
    loginSheet: getLoginSheetContent(LOGIN_SHEET_SCENARIOS.PLAY_UNLOCK),
    playButtonText: '开始播放',
    audioDebug: buildAudioDebug()
  },

  onLoad: function (options) {
    const lessonId = options.id || getContinueLesson().id;
    const lesson = getLessonById(lessonId) || getContinueLesson();

    this.audioTempFiles = Object.create(null);
    this.downloadTask = null;
    this.audioSourcePath = '';
    this.audioRequestUrl = '';
    this.trialSession = null;
    this.trialLimitHandled = false;
    this.isLoggingIn = false;

    this.setData({
      lesson: lesson,
      category: getCategoryById(lesson.categoryId),
      recommendationList: getRecommendedLessonsFor(lesson.id),
      playButtonText: getDefaultPlayButtonText(lesson),
      audioDebug: buildAudioDebug({
        source: lesson.audioUrl || lesson.sourcePath || '',
        status: '页面已加载'
      })
    });

    this.setupAudioContext();
    this.syncPageState();
  },

  onShow: function () {
    this.syncPageState();
  },

  onUnload: function () {
    this.cancelDownloadTask();
    this.destroyAudioContext();
    this.endTrialSession();
  },

  handleSegmentTap: function (event) {
    this.setData({
      activeSegmentIndex: Number(event.currentTarget.dataset.index)
    });
  },

  syncPageState: function () {
    const lesson = this.data.lesson;
    const isGuestMode = !auth.isLoggedIn();
    const trialState = trial.getTrialState();
    const hasAudio = Boolean(lesson && (lesson.audioUrl || lesson.sourcePath));

    if (!isGuestMode && this.data.isTrialMode) {
      this.endTrialSession();
    }

    this.setData({
      isGuestMode: isGuestMode,
      isCollected: !isGuestMode && lesson ? this.isLessonCollected(lesson.id) : false,
      trialCount: trialState.count,
      trialMaxCount: trialState.maxCount,
      trialMaxSeconds: trialState.maxSeconds,
      showTrialBanner: isGuestMode && hasAudio
    });
  },

  togglePlay: function () {
    const lesson = this.data.lesson;

    if (!lesson) {
      return;
    }

    if (!lesson.audioUrl && !lesson.sourcePath) {
      this.toggleDemoPlayback();
      return;
    }

    if (this.data.isPlaying && this.audioContext) {
      this.audioContext.pause();
      return;
    }

    const audioSource = lesson.audioUrl || lesson.sourcePath;

    if (this.isUnsupportedAudio(audioSource)) {
      this.updateAudioDebug({
        status: '音频格式暂不支持',
        source: audioSource,
        lastError: '当前文件需要先转换为 MP3 或 M4A',
        lastEvent: 'unsupported-format'
      });

      wx.showToast({
        title: '当前素材请先转换成 MP3 或 M4A',
        icon: 'none',
        duration: 2600
      });
      return;
    }

    if (!this.audioContext) {
      this.setupAudioContext();
    }

    if (!this.audioContext) {
      this.updateAudioDebug({
        status: '播放器初始化失败',
        source: audioSource,
        lastError: 'wx.createInnerAudioContext 不可用',
        lastEvent: 'init-failed'
      });

      wx.showToast({
        title: '播放器初始化失败',
        icon: 'none'
      });
      return;
    }

    if (!auth.isLoggedIn()) {
      if (this.isTrialSessionActiveForLesson(lesson.id)) {
        this.startPlayback(audioSource, false);
        return;
      }

      const trialState = trial.canStartTrial();

      if (!trialState.allowed) {
        this.openLoginSheet(LOGIN_SHEET_SCENARIOS.QUOTA_EXHAUSTED, {
          type: 'play',
          lessonId: lesson.id
        });
        return;
      }

      this.startPlayback(audioSource, true, trialState);
      return;
    }

    this.startPlayback(audioSource, false);
  },

  startPlayback: function (audioSource, shouldStartTrial, trialState) {
    this.prepareAudioSource(audioSource)
      .then((playableSource) => {
        if (shouldStartTrial) {
          const consumedTrial = trial.consumeTrialCount();
          this.beginTrialSession(this.data.lesson.id, consumedTrial);
        }

        if (this.audioSourcePath !== playableSource) {
          this.audioContext.src = playableSource;
          this.audioSourcePath = playableSource;
        }

        this.audioRequestUrl = audioSource;
        this.updateAudioDebug({
          status: shouldStartTrial ? '试听准备中' : '准备播放',
          source: audioSource,
          lastError: '',
          lastEvent: shouldStartTrial ? 'trial-play-called' : 'play-called'
        });

        this.audioContext.play();
      })
      .catch((error) => {
        const errorMessage = this.formatAudioError(error);

        this.updateAudioDebug({
          status: '音频准备失败',
          source: audioSource,
          lastError: errorMessage,
          lastEvent: 'prepare-error'
        });

        wx.showToast({
          title: this.isLocalDevAudio(audioSource)
            ? '手机暂时连不到电脑的音频服务，请检查同一 Wi-Fi 和电脑防火墙'
            : '音频准备失败，请稍后重试',
          icon: 'none',
          duration: 2800
        });
      });
  },

  toggleDemoPlayback: function () {
    const nextState = !this.data.isPlaying;

    this.setData({
      isPlaying: nextState
    });

    this.updateAudioDebug({
      status: nextState ? '演示模式播放中' : '演示模式已暂停',
      lastEvent: nextState ? 'demo-play' : 'demo-pause'
    });

    wx.showToast({
      title: nextState ? '已开始播放演示内容' : '已暂停播放',
      icon: 'none'
    });
  },

  toggleFollowRead: function () {
    const nextState = !this.data.isFollowReading;

    this.setData({
      isFollowReading: nextState
    });

    wx.showToast({
      title: nextState ? '跟读模式已开启' : '跟读模式已关闭',
      icon: 'none'
    });
  },

  toggleCollect: function () {
    const lesson = this.data.lesson;

    if (!lesson) {
      return;
    }

    if (!auth.isLoggedIn()) {
      this.openLoginSheet(LOGIN_SHEET_SCENARIOS.FAVORITE_GUARD, {
        type: 'favorite',
        lessonId: lesson.id
      });
      return;
    }

    this.performFavoriteToggle();
  },

  performFavoriteToggle: function () {
    const lesson = this.data.lesson;
    const storageKey = this.getFavoritesStorageKey();

    if (!lesson || !storageKey) {
      return;
    }

    const favoriteIds = this.getFavoriteIds();
    const targetIndex = favoriteIds.indexOf(lesson.id);
    let nextFavoriteIds = favoriteIds.slice();
    let isCollected = false;

    if (targetIndex === -1) {
      nextFavoriteIds.push(lesson.id);
      isCollected = true;
    } else {
      nextFavoriteIds.splice(targetIndex, 1);
    }

    wx.setStorageSync(storageKey, nextFavoriteIds);
    this.setData({
      isCollected: isCollected
    });

    wx.showToast({
      title: isCollected ? '已加入收藏' : '已取消收藏',
      icon: 'none'
    });
  },

  openRecommendation: function (event) {
    const lesson = event.detail;

    if (!lesson || !lesson.id) {
      return;
    }

    this.cancelDownloadTask();
    this.endTrialSession();

    if (this.audioContext) {
      this.audioContext.stop();
    }

    wx.redirectTo({
      url: '/pages/tool/index?id=' + lesson.id
    });
  },

  openLoginSheet: function (scenario, pendingAction) {
    if (pendingAction) {
      auth.savePendingAction(pendingAction);
    }

    this.setData({
      showLoginSheet: true,
      loginSheet: getLoginSheetContent(scenario)
    });
  },

  closeLoginSheet: function () {
    auth.consumePendingAction();
    this.setData({
      showLoginSheet: false
    });
  },

  handleLoginConfirm: function () {
    if (this.isLoggingIn) {
      return;
    }

    this.isLoggingIn = true;

    auth.loginWithWechat()
      .then(() => {
        const pendingAction = auth.consumePendingAction();

        this.isLoggingIn = false;
        this.setData({
          showLoginSheet: false
        });

        this.endTrialSession();
        this.syncPageState();

        wx.showToast({
          title: COPY.loginSuccessToast,
          icon: 'none'
        });

        this.resumePendingAction(pendingAction);
      })
      .catch((error) => {
        this.isLoggingIn = false;
        auth.clearLoginSession();
        auth.consumePendingAction();
        this.setData({
          showLoginSheet: false
        });

        console.error('login failed', error);
        wx.showToast({
          title: COPY.loginFailedToast,
          icon: 'none'
        });
      });
  },

  resumePendingAction: function (pendingAction) {
    if (!pendingAction) {
      return;
    }

    if (pendingAction.type === 'play') {
      if (pendingAction.lessonId === this.data.lesson.id) {
        this.togglePlay();
        return;
      }

      wx.redirectTo({
        url: '/pages/tool/index?id=' + pendingAction.lessonId
      });
      return;
    }

    if (pendingAction.type === 'favorite' && pendingAction.lessonId === this.data.lesson.id) {
      this.performFavoriteToggle();
    }
  },

  beginTrialSession: function (lessonId, trialInfo) {
    const currentTrial = trialInfo || trial.getTrialState();

    this.trialSession = {
      lessonId: lessonId,
      startedAt: Date.now(),
      count: currentTrial.count
    };
    this.trialLimitHandled = false;

    this.setData({
      isTrialMode: true,
      trialCount: currentTrial.count,
      trialMaxCount: currentTrial.maxCount,
      trialMaxSeconds: currentTrial.maxSeconds,
      showTrialBanner: true
    });
  },

  endTrialSession: function () {
    this.trialSession = null;
    this.trialLimitHandled = false;

    this.setData({
      isTrialMode: false,
      showTrialBanner: this.data.isGuestMode && Boolean(
        this.data.lesson && (this.data.lesson.audioUrl || this.data.lesson.sourcePath)
      )
    });
  },

  isTrialSessionActiveForLesson: function (lessonId) {
    return Boolean(
      this.trialSession &&
      this.trialSession.lessonId === lessonId &&
      !this.trialLimitHandled
    );
  },

  handleTrialLimitReached: function () {
    const lesson = this.data.lesson;

    if (!lesson || this.trialLimitHandled) {
      return;
    }

    this.trialLimitHandled = true;

    if (this.audioContext) {
      this.audioContext.stop();
    }

    this.updateAudioDebug({
      status: '试听已结束',
      lastEvent: 'trial-limit',
      lastError: ''
    });

    this.endTrialSession();
    this.openLoginSheet(LOGIN_SHEET_SCENARIOS.TRIAL_FINISHED, {
      type: 'play',
      lessonId: lesson.id
    });
  },

  getFavoritesStorageKey: function () {
    const session = auth.getSession();
    return session.userId ? FAVORITES_KEY_PREFIX + session.userId : '';
  },

  getFavoriteIds: function () {
    const storageKey = this.getFavoritesStorageKey();

    if (!storageKey) {
      return [];
    }

    try {
      const storedValue = wx.getStorageSync(storageKey);
      return Array.isArray(storedValue) ? storedValue : [];
    } catch (error) {
      console.warn('get favorites failed', error);
      return [];
    }
  },

  isLessonCollected: function (lessonId) {
    return this.getFavoriteIds().indexOf(lessonId) !== -1;
  },

  setupAudioContext: function () {
    if (this.audioContext || !wx.createInnerAudioContext) {
      return;
    }

    const audioContext = wx.createInnerAudioContext();
    audioContext.autoplay = false;

    if (Object.prototype.hasOwnProperty.call(audioContext, 'obeyMuteSwitch')) {
      audioContext.obeyMuteSwitch = false;
    }

    this.updateAudioDebug({
      status: '播放器已创建',
      lastEvent: 'context-created'
    });

    audioContext.onCanplay(() => {
      this.updateAudioDebug({
        status: '音频已就绪',
        lastEvent: 'canplay',
        lastError: ''
      });
    });

    audioContext.onWaiting(() => {
      this.updateAudioDebug({
        status: '音频缓冲中',
        lastEvent: 'waiting'
      });
    });

    audioContext.onPlay(() => {
      this.setData({
        isPlaying: true,
        playButtonText: '暂停播放'
      });

      this.updateAudioDebug({
        status: this.data.isTrialMode ? '试听播放中' : '播放中',
        lastEvent: 'play',
        lastError: ''
      });
    });

    audioContext.onPause(() => {
      this.setData({
        isPlaying: false,
        playButtonText: '继续播放'
      });

      this.updateAudioDebug({
        status: '已暂停',
        lastEvent: 'pause'
      });
    });

    audioContext.onStop(() => {
      this.setData({
        isPlaying: false,
        playButtonText: getDefaultPlayButtonText(this.data.lesson)
      });

      this.updateAudioDebug({
        status: '已停止',
        lastEvent: 'stop'
      });
    });

    audioContext.onEnded(() => {
      this.setData({
        isPlaying: false,
        playButtonText: '重新播放'
      });

      this.updateAudioDebug({
        status: '播放结束',
        lastEvent: 'ended'
      });

      if (this.data.isTrialMode) {
        this.endTrialSession();
      }
    });

    audioContext.onTimeUpdate(() => {
      const currentTime = (audioContext.currentTime || 0).toFixed(1) + 's';

      if (this.data.isTrialMode && audioContext.currentTime >= this.data.trialMaxSeconds) {
        this.updateAudioDebug({
          currentTime: currentTime,
          lastEvent: 'trial-timeupdate'
        });
        this.handleTrialLimitReached();
        return;
      }

      this.updateAudioDebug({
        currentTime: currentTime,
        lastEvent: 'timeupdate'
      });
    });

    audioContext.onError((error) => {
      const errorMessage = this.formatAudioError(error);

      this.setData({
        isPlaying: false,
        playButtonText: getDefaultPlayButtonText(this.data.lesson)
      });

      this.updateAudioDebug({
        status: '播放失败',
        lastEvent: 'error',
        lastError: errorMessage
      });

      if (this.data.isTrialMode) {
        this.endTrialSession();
      }

      console.error('audio play error', error);
      wx.showToast({
        title: this.isLocalDevAudio(this.audioRequestUrl)
          ? '音频已下载但播放失败，请把播放器状态截图给我'
          : '音频播放失败，请检查文件格式或路径',
        icon: 'none',
        duration: 2600
      });
    });

    this.audioContext = audioContext;
  },

  prepareAudioSource: function (audioSource) {
    if (!audioSource) {
      return Promise.reject(new Error('音频地址为空'));
    }

    if (!this.shouldDownloadBeforePlay(audioSource)) {
      return Promise.resolve(audioSource);
    }

    if (this.audioTempFiles[audioSource]) {
      this.updateAudioDebug({
        status: '已命中本地缓存',
        source: audioSource,
        lastError: '',
        lastEvent: 'cache-hit'
      });
      return Promise.resolve(this.audioTempFiles[audioSource]);
    }

    if (!wx.downloadFile) {
      return Promise.reject(new Error('当前环境不支持下载音频'));
    }

    this.cancelDownloadTask();

    return this.probeLocalAudioServer(audioSource).then(() => {
      this.updateAudioDebug({
        status: '音频下载中',
        source: audioSource,
        lastError: '',
        lastEvent: 'download-start'
      });

      return new Promise((resolve, reject) => {
        const task = wx.downloadFile({
          url: audioSource,
          timeout: AUDIO_DOWNLOAD_TIMEOUT,
          success: (res) => {
            this.downloadTask = null;

            if (res.statusCode !== 200 || !res.tempFilePath) {
              reject(new Error('下载失败，状态码 ' + res.statusCode));
              return;
            }

            this.audioTempFiles[audioSource] = res.tempFilePath;
            this.updateAudioDebug({
              status: '音频已下载到本地',
              source: audioSource,
              lastError: '',
              lastEvent: 'download-success'
            });

            resolve(res.tempFilePath);
          },
          fail: (error) => {
            this.downloadTask = null;
            reject(error);
          }
        });

        this.downloadTask = task;

        if (task && task.onProgressUpdate) {
          task.onProgressUpdate((progress) => {
            this.updateAudioDebug({
              status: '音频下载中 ' + progress.progress + '%',
              source: audioSource,
              lastEvent: 'download-progress'
            });
          });
        }
      });
    });
  },

  probeLocalAudioServer: function (audioSource) {
    if (!this.isLocalDevAudio(audioSource) || !wx.request) {
      return Promise.resolve();
    }

    const serverOrigin = this.getUrlOrigin(audioSource);

    if (!serverOrigin) {
      return Promise.resolve();
    }

    this.updateAudioDebug({
      status: '正在检查局域网音频服务',
      source: audioSource,
      lastError: '',
      lastEvent: 'probe-start'
    });

    return new Promise((resolve, reject) => {
      wx.request({
        url: serverOrigin + '/health',
        method: 'GET',
        timeout: LOCAL_AUDIO_PROBE_TIMEOUT,
        success: (res) => {
          if (res.statusCode >= 200 && res.statusCode < 300) {
            this.updateAudioDebug({
              status: '局域网音频服务可达',
              source: audioSource,
              lastError: '',
              lastEvent: 'probe-success'
            });
            resolve();
            return;
          }

          reject(new Error('局域网音频服务返回状态码 ' + res.statusCode));
        },
        fail: (error) => {
          reject(new Error('局域网音频服务不可达：' + this.formatAudioError(error)));
        }
      });
    });
  },

  cancelDownloadTask: function () {
    if (!this.downloadTask) {
      return;
    }

    if (this.downloadTask.abort) {
      this.downloadTask.abort();
    }

    this.downloadTask = null;
  },

  destroyAudioContext: function () {
    if (!this.audioContext) {
      return;
    }

    this.audioContext.destroy();
    this.audioContext = null;
    this.audioSourcePath = '';
    this.audioRequestUrl = '';
  },

  updateAudioDebug: function (patch) {
    this.setData({
      audioDebug: Object.assign({}, this.data.audioDebug, patch || {})
    });
  },

  formatAudioError: function (error) {
    if (!error) {
      return '未知错误';
    }

    const code = error.errCode || error.code || '';
    const message = error.errMsg || error.message || '未知错误';
    return code ? '错误码 ' + code + '：' + message : message;
  },

  getUrlOrigin: function (sourcePath) {
    const match = /^https?:\/\/[^/]+/i.exec(sourcePath || '');
    return match ? match[0] : '';
  },

  shouldDownloadBeforePlay: function (sourcePath) {
    return /^http:\/\//i.test(sourcePath);
  },

  isUnsupportedAudio: function (sourcePath) {
    return /\.m4b$/i.test(sourcePath);
  },

  isLocalDevAudio: function (sourcePath) {
    if (!sourcePath) {
      return false;
    }

    return /^http:\/\/(?:127\.0\.0\.1|localhost|192\.168\.|10\.|172\.(?:1[6-9]|2\d|3[0-1])\.)/i.test(sourcePath);
  }
});
