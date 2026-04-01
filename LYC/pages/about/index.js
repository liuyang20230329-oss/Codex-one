const { PARENT_PANEL } = require('../../utils/content-data');
const auth = require('../../utils/auth');
const {
  COPY,
  LOGIN_SHEET_SCENARIOS,
  getLoginSheetContent
} = require('../../utils/copy');

Page({
  data: {
    observations: PARENT_PANEL.observations,
    schedules: PARENT_PANEL.schedules,
    tips: PARENT_PANEL.tips,
    todo: PARENT_PANEL.todo,
    quietModeEnabled: true,
    isGuestMode: true,
    userProfile: auth.getUserProfile(),
    showLoginSheet: false,
    loginSheet: getLoginSheetContent(LOGIN_SHEET_SCENARIOS.PARENT_GUARD)
  },

  onShow: function () {
    this.syncTabBar(3);
    this.syncAuthState();
  },

  syncAuthState: function () {
    this.setData({
      isGuestMode: !auth.isLoggedIn(),
      userProfile: auth.getUserProfile()
    });
  },

  toggleQuietMode: function () {
    if (this.data.isGuestMode) {
      this.openLoginSheet();
      return;
    }

    const nextState = !this.data.quietModeEnabled;

    this.setData({
      quietModeEnabled: nextState
    });

    wx.showToast({
      title: nextState ? '已开启温和提醒' : '已关闭温和提醒',
      icon: 'none'
    });
  },

  openDiscover: function () {
    wx.switchTab({
      url: '/pages/discover/index'
    });
  },

  openLoginSheet: function () {
    auth.savePendingAction({
      type: 'parent_access'
    });

    this.setData({
      showLoginSheet: true,
      loginSheet: getLoginSheetContent(LOGIN_SHEET_SCENARIOS.PARENT_GUARD)
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

        console.error('parent login failed', error);
        wx.showToast({
          title: COPY.loginFailedToast,
          icon: 'none'
        });
      });
  },

  handleLogout: function () {
    auth.logout();
    this.syncAuthState();

    wx.showToast({
      title: '已退出登录',
      icon: 'none'
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
