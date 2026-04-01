const {
  CATEGORY_LIST,
  getCategoryById,
  getLessonsByCategory
} = require('../../utils/content-data');

Page({
  data: {
    categories: CATEGORY_LIST,
    currentCategoryId: CATEGORY_LIST[0].id,
    currentCategory: CATEGORY_LIST[0],
    lessonList: getLessonsByCategory(CATEGORY_LIST[0].id)
  },

  onShow: function () {
    this.syncTabBar(1);

    const cachedCategoryId = wx.getStorageSync('lycSelectedCategoryId');

    if (cachedCategoryId) {
      this.updateCategory(cachedCategoryId);
      wx.removeStorageSync('lycSelectedCategoryId');
    }
  },

  handleCategoryTap: function (event) {
    const categoryId = event.currentTarget.dataset.id;
    this.updateCategory(categoryId);
  },

  handleLessonSelect: function (event) {
    const lesson = event.detail;

    if (!lesson || !lesson.id) {
      return;
    }

    wx.navigateTo({
      url: '/pages/tool/index?id=' + lesson.id
    });
  },

  updateCategory: function (categoryId) {
    const category = getCategoryById(categoryId);

    if (!category) {
      return;
    }

    this.setData({
      currentCategoryId: categoryId,
      currentCategory: category,
      lessonList: getLessonsByCategory(categoryId)
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
