const LOGIN_SHEET_SCENARIOS = {
  PLAY_UNLOCK: 'play_unlock',
  TRIAL_FINISHED: 'trial_finished',
  QUOTA_EXHAUSTED: 'quota_exhausted',
  FAVORITE_GUARD: 'favorite_guard',
  GROWTH_GUARD: 'growth_guard',
  PARENT_GUARD: 'parent_guard'
};

const COPY = {
  trialBanner: '当前为试听内容，登录后可完整收听',
  loginSuccessToast: '登录成功，已为你解锁完整内容',
  loginFailedToast: '登录失败，请稍后重试',
  loginSheetPrimary: '微信登录继续',
  loginSheetSecondary: '稍后再说'
};

function getLoginSheetContent(scenario) {
  switch (scenario) {
    case LOGIN_SHEET_SCENARIOS.TRIAL_FINISHED:
      return {
        title: '试听结束啦',
        body: '登录后可继续完整收听，还能保存学习记录和收藏内容',
        primaryText: COPY.loginSheetPrimary,
        secondaryText: COPY.loginSheetSecondary
      };
    case LOGIN_SHEET_SCENARIOS.QUOTA_EXHAUSTED:
      return {
        title: '今日试听次数已用完',
        body: '登录后可继续收听全部内容，还能查看成长记录',
        primaryText: '登录解锁',
        secondaryText: '返回看看'
      };
    case LOGIN_SHEET_SCENARIOS.FAVORITE_GUARD:
      return {
        title: '登录后可收藏内容',
        body: '登录后可保存喜欢的课程，方便下次继续陪孩子学习',
        primaryText: COPY.loginSheetPrimary,
        secondaryText: COPY.loginSheetSecondary
      };
    case LOGIN_SHEET_SCENARIOS.GROWTH_GUARD:
      return {
        title: '登录后查看成长记录',
        body: '登录后可查看成长星星、学习时长和连续学习天数',
        primaryText: COPY.loginSheetPrimary,
        secondaryText: COPY.loginSheetSecondary
      };
    case LOGIN_SHEET_SCENARIOS.PARENT_GUARD:
      return {
        title: '登录后进入家长中心',
        body: '登录后可保存陪伴计划、查看孩子最近的学习偏好和建议',
        primaryText: COPY.loginSheetPrimary,
        secondaryText: COPY.loginSheetSecondary
      };
    case LOGIN_SHEET_SCENARIOS.PLAY_UNLOCK:
    default:
      return {
        title: '登录后继续学习',
        body: '登录后可完整收听，还能保存学习记录和收藏内容',
        primaryText: COPY.loginSheetPrimary,
        secondaryText: COPY.loginSheetSecondary
      };
  }
}

module.exports = {
  COPY: COPY,
  LOGIN_SHEET_SCENARIOS: LOGIN_SHEET_SCENARIOS,
  getLoginSheetContent: getLoginSheetContent
};
