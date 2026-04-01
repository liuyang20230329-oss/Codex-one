const STORAGE_KEYS = {
  trialDate: 'lyc_trial_date',
  trialCount: 'lyc_trial_count'
};

const TRIAL_MAX_SECONDS = 30;
const TRIAL_MAX_COUNT_PER_DAY = 3;

function getTodayDateKey(date) {
  const current = date ? new Date(date) : new Date();
  const year = current.getFullYear();
  const month = String(current.getMonth() + 1).padStart(2, '0');
  const day = String(current.getDate()).padStart(2, '0');
  return year + '-' + month + '-' + day;
}

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
    console.warn('trial storage failed', key, error);
  }
}

function resetTrialCountIfNeeded() {
  const today = getTodayDateKey();
  const storedDate = safeGetStorage(STORAGE_KEYS.trialDate, '');

  if (storedDate !== today) {
    safeSetStorage(STORAGE_KEYS.trialDate, today);
    safeSetStorage(STORAGE_KEYS.trialCount, 0);
  }
}

function getTrialCount() {
  resetTrialCountIfNeeded();
  return Number(safeGetStorage(STORAGE_KEYS.trialCount, 0)) || 0;
}

function getTrialConfig() {
  return {
    maxSeconds: TRIAL_MAX_SECONDS,
    maxCountPerDay: TRIAL_MAX_COUNT_PER_DAY
  };
}

function getTrialState() {
  const count = getTrialCount();
  const remainCount = Math.max(TRIAL_MAX_COUNT_PER_DAY - count, 0);

  return {
    date: safeGetStorage(STORAGE_KEYS.trialDate, getTodayDateKey()),
    count: count,
    maxCount: TRIAL_MAX_COUNT_PER_DAY,
    remainCount: remainCount,
    maxSeconds: TRIAL_MAX_SECONDS
  };
}

function canStartTrial() {
  const state = getTrialState();
  return Object.assign({}, state, {
    allowed: state.count < state.maxCount
  });
}

function consumeTrialCount() {
  const state = canStartTrial();

  if (!state.allowed) {
    return state;
  }

  const nextCount = state.count + 1;
  safeSetStorage(STORAGE_KEYS.trialDate, getTodayDateKey());
  safeSetStorage(STORAGE_KEYS.trialCount, nextCount);

  return {
    allowed: true,
    count: nextCount,
    maxCount: TRIAL_MAX_COUNT_PER_DAY,
    remainCount: Math.max(TRIAL_MAX_COUNT_PER_DAY - nextCount, 0),
    maxSeconds: TRIAL_MAX_SECONDS
  };
}

module.exports = {
  STORAGE_KEYS: STORAGE_KEYS,
  TRIAL_MAX_SECONDS: TRIAL_MAX_SECONDS,
  TRIAL_MAX_COUNT_PER_DAY: TRIAL_MAX_COUNT_PER_DAY,
  getTodayDateKey: getTodayDateKey,
  resetTrialCountIfNeeded: resetTrialCountIfNeeded,
  getTrialCount: getTrialCount,
  getTrialState: getTrialState,
  canStartTrial: canStartTrial,
  consumeTrialCount: consumeTrialCount,
  getTrialConfig: getTrialConfig
};
