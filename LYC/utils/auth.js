const STORAGE_KEYS = {
  loginState: 'lyc_login_state',
  loginToken: 'lyc_login_token',
  userId: 'lyc_user_id',
  userProfile: 'lyc_user_profile',
  lastLoginTime: 'lyc_last_login_time',
  pendingAction: 'lyc_pending_action'
};

const LOGIN_STATES = {
  GUEST: 'GUEST',
  LOGGING_IN: 'LOGGING_IN',
  AUTHENTICATED: 'AUTHENTICATED',
  AUTH_FAILED: 'AUTH_FAILED',
  AUTH_EXPIRED: 'AUTH_EXPIRED'
};

function safeGetStorage(key, fallbackValue) {
  try {
    const value = wx.getStorageSync(key);
    return value === '' || value === undefined ? fallbackValue : value;
  } catch (error) {
    return fallbackValue;
  }
}

function safeSetStorage(key, value) {
  try {
    wx.setStorageSync(key, value);
  } catch (error) {
    console.warn('set storage failed', key, error);
  }
}

function safeRemoveStorage(key) {
  try {
    wx.removeStorageSync(key);
  } catch (error) {
    console.warn('remove storage failed', key, error);
  }
}

function getLoginState() {
  return safeGetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.GUEST);
}

function isLoggedIn() {
  return getLoginState() === LOGIN_STATES.AUTHENTICATED;
}

function getUserProfile() {
  return safeGetStorage(STORAGE_KEYS.userProfile, {
    nickname: '学习家长',
    avatarUrl: ''
  });
}

function getSession() {
  return {
    loginState: getLoginState(),
    token: safeGetStorage(STORAGE_KEYS.loginToken, ''),
    userId: safeGetStorage(STORAGE_KEYS.userId, ''),
    lastLoginTime: safeGetStorage(STORAGE_KEYS.lastLoginTime, 0),
    profile: getUserProfile()
  };
}

function saveLoginSession(session) {
  safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.AUTHENTICATED);
  safeSetStorage(STORAGE_KEYS.loginToken, session.token || '');
  safeSetStorage(STORAGE_KEYS.userId, session.userId || '');
  safeSetStorage(STORAGE_KEYS.userProfile, session.profile || getUserProfile());
  safeSetStorage(STORAGE_KEYS.lastLoginTime, session.lastLoginTime || Date.now());
  return getSession();
}

function clearLoginSession() {
  safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.GUEST);
  safeRemoveStorage(STORAGE_KEYS.loginToken);
  safeRemoveStorage(STORAGE_KEYS.userId);
  safeRemoveStorage(STORAGE_KEYS.userProfile);
  safeRemoveStorage(STORAGE_KEYS.lastLoginTime);
}

function savePendingAction(action) {
  safeSetStorage(STORAGE_KEYS.pendingAction, action || null);
}

function consumePendingAction() {
  const action = safeGetStorage(STORAGE_KEYS.pendingAction, null);
  safeRemoveStorage(STORAGE_KEYS.pendingAction);
  return action;
}

function buildMockSession(code) {
  const shortCode = (code || '').slice(-8) || String(Date.now()).slice(-8);
  return {
    userId: 'lyc_user_' + shortCode,
    token: 'lyc_token_' + Date.now(),
    lastLoginTime: Date.now(),
    profile: {
      nickname: '学习家长',
      avatarUrl: ''
    }
  };
}

function loginWithWechat() {
  safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.LOGGING_IN);

  return new Promise((resolve, reject) => {
    if (!wx.login) {
      safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.AUTH_FAILED);
      reject(new Error('当前环境不支持微信登录'));
      return;
    }

    wx.login({
      success: function (res) {
        if (!res.code) {
          safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.AUTH_FAILED);
          reject(new Error('未获取到微信登录凭证'));
          return;
        }

        const session = buildMockSession(res.code);
        resolve(saveLoginSession(session));
      },
      fail: function (error) {
        safeSetStorage(STORAGE_KEYS.loginState, LOGIN_STATES.AUTH_FAILED);
        reject(error);
      }
    });
  });
}

function logout() {
  clearLoginSession();
  consumePendingAction();
}

module.exports = {
  LOGIN_STATES: LOGIN_STATES,
  STORAGE_KEYS: STORAGE_KEYS,
  getLoginState: getLoginState,
  getSession: getSession,
  getUserProfile: getUserProfile,
  isLoggedIn: isLoggedIn,
  saveLoginSession: saveLoginSession,
  clearLoginSession: clearLoginSession,
  savePendingAction: savePendingAction,
  consumePendingAction: consumePendingAction,
  loginWithWechat: loginWithWechat,
  logout: logout
};
