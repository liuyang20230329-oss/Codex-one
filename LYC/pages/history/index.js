const {
  GROWTH_PANEL,
  getContinueLesson
} = require('../../utils/content-data');
const auth = require('../../utils/auth');
const {
  COPY,
  LOGIN_SHEET_SCENARIOS,
  getLoginSheetContent
} = require('../../utils/copy');

Page({
  data: {
    totalStars: GROWTH_PANEL.totalStars,
    streakDays: GROWTH_PANEL.streakDays,
    totalMinutes: GROWTH_PANEL.totalMinutes,
    weekProgress: GROWTH_PANEL.weekProgress,
    missions: GROWTH_PANEL.missions,
    badges: GROWTH_PANEL.badges,
    continueLesson: getContinueLesson(),
    isGuestMode: true,
    showLoginSheet: false,
    loginSheet: getLoginSheetContent(LOGIN_SHEET_SCENARIOS.GROWTH_GUARD)
  },

  onShow: function () {
    this.syncTabBar(2);
    this.syncAuthState();
  },

  syncAuthState: function () {
    this.setData({
      isGuestMode: !auth.isLoggedIn()
    });
  },

  openContinue: function () {
    if (this.data.isGuestMode) {
      this.openLoginSheet();
      return;
    }

    wx.navigateTo({
      url: '/pages/tool/index?id=' + this.data.continueLesson.id
    });
  },

  claimMission: function (event) {
    const title = event.currentTarget.dataset.title;

    if (this.data.isGuestMode) {
      this.openLoginSheet();
      return;
    }

    wx.showToast({
      title: title + ' 已记录',
      icon: 'none'
    });
  },

  openLoginSheet: function () {
    auth.savePendingAction({
      type: 'growth_access'
    });

    this.setData({
      showLoginSheet: true,
      loginSheet: getLoginSheetContent(LOGIN_SHEET_SCENARIOS.GROWTH_GUARD)
    });
  },

  closeLoginSheet: function () {
    auth.consumePendingAction();
    this.setData({
      showLoginSheet: false
    });
  },

  handleLoginConfirm: function () {
    auth.loginWithWechat()
      .then(() => {
        auth.consumePendingAction();
        this.setData({
          showLoginSheet: false
        });
        this.syncAuthState();

        wx.showToast({
          title: COPY.loginSuccessToast,
          icon: 'none'
        });
      })
      .catch((error) => {
        auth.clearLoginSession();
        auth.consumePendingAction();
        this.setData({
          showLoginSheet: false
        });

        console.error('growth login failed', error);
        wx.showToast({
          title: COPY.loginFailedToast,
          icon: 'none'
        });
      });
  },

  syncTabBar: function (selected) {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({
        selected: selected
      });
    }
  }
});
