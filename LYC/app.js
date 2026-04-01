const auth = require('./utils/auth');

const CLOUD_ENV_ID = '';

App({
  onLaunch: function () {
    if (wx.setInnerAudioOption) {
      wx.setInnerAudioOption({
        mixWithOther: false,
        obeyMuteSwitch: false
      });
    }

    this.globalData.loginState = auth.getLoginState();

    if (!wx.cloud) {
      this.globalData.cloudSupported = false;
      return;
    }

    this.globalData.cloudSupported = true;

    if (CLOUD_ENV_ID) {
      wx.cloud.init({
        env: CLOUD_ENV_ID,
        traceUser: true
      });

      this.globalData.cloudEnabled = true;
      this.globalData.cloudEnvId = CLOUD_ENV_ID;
    }
  },

  globalData: {
    appName: 'LYC 小宇宙学堂',
    loginState: auth.getLoginState(),
    cloudSupported: false,
    cloudEnabled: false,
    cloudEnvId: '',
    owner: 'LYC'
  }
});
