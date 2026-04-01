const {
  CATEGORY_LIST,
  GROWTH_PANEL,
  HOME_PLAYLISTS,
  getContinueLesson,
  getLessonsByIds
} = require('../../utils/content-data');

Page({
  data: {
    statusBarHeight: 20,
    navBarHeight: 88,
    navPanelHeight: 50,
    navSpacerHeight: 108,
    navContentHeight: 32,
    capsuleReserve: 96,
    categories: CATEGORY_LIST,
    continueLesson: getContinueLesson(),
    todayLessons: getLessonsByIds(HOME_PLAYLISTS.todayIds),
    bedtimeLessons: getLessonsByIds(HOME_PLAYLISTS.bedtimeIds),
    totalStars: GROWTH_PANEL.totalStars,
    streakDays: GROWTH_PANEL.streakDays
  },

  onLoad: function () {
    const systemInfo = wx.getSystemInfoSync();
    const statusBarHeight = systemInfo.statusBarHeight || 20;
    let navContentHeight = 32;
    let capsuleReserve = 96;
    let navBarHeight = statusBarHeight + 44;
    let navPanelHeight = navContentHeight + 18;

    if (wx.getMenuButtonBoundingClientRect) {
      const menuButtonRect = wx.getMenuButtonBoundingClientRect();

      if (menuButtonRect && menuButtonRect.width) {
        const navGap = menuButtonRect.top - statusBarHeight;
        navContentHeight = menuButtonRect.height;
        capsuleReserve = systemInfo.screenWidth - menuButtonRect.left + 16;
        navBarHeight = statusBarHeight + navGap * 2 + navContentHeight;
        navPanelHeight = navContentHeight + 18;
      }
    }

    this.setData({
      statusBarHeight: statusBarHeight,
      navBarHeight: navBarHeight,
      navPanelHeight: navPanelHeight,
      navSpacerHeight: navBarHeight + 26,
      navContentHeight: navContentHeight,
      capsuleReserve: capsuleReserve
    });
  },

  onShow: function () {
    this.syncTabBar(0);
  },

  openContinue: function () {
    const lesson = this.data.continueLesson;

    if (!lesson) {
      return;
    }

    this.openLessonById(lesson.id);
  },

  openLesson: function (event) {
    const lesson = event.detail;

    if (!lesson || !lesson.id) {
      return;
    }

    this.openLessonById(lesson.id);
  },

  openCategory: function (event) {
    const category = event.detail;

    if (!category || !category.id) {
      return;
    }

    wx.setStorageSync('lycSelectedCategoryId', category.id);
    wx.switchTab({
      url: '/pages/discover/index'
    });
  },

  goDiscover: function () {
    wx.switchTab({
      url: '/pages/discover/index'
    });
  },

  goGrowth: function () {
    wx.switchTab({
      url: '/pages/history/index'
    });
  },

  openLessonById: function (lessonId) {
    wx.navigateTo({
      url: '/pages/tool/index?id=' + lessonId
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
