Component({
  data: {
    selected: 0,
    color: '#7b8798',
    selectedColor: '#ff8f62',
    list: [
      {
        pagePath: '/pages/home/index',
        text: '父亲',
        iconPath: '/assets/tabbar/home.png',
        selectedIconPath: '/assets/tabbar/home-active.png'
      },
      {
        pagePath: '/pages/discover/index',
        text: '妈妈',
        iconPath: '/assets/tabbar/discover.png',
        selectedIconPath: '/assets/tabbar/discover-active.png'
      },
      {
        pagePath: '/pages/history/index',
        text: '宝贝',
        iconPath: '/assets/tabbar/growth.png',
        selectedIconPath: '/assets/tabbar/growth-active.png'
      },
      {
        pagePath: '/pages/about/index',
        text: 'Family',
        iconPath: '/assets/tabbar/parent.png',
        selectedIconPath: '/assets/tabbar/parent-active.png'
      }
    ]
  },

  methods: {
    switchTab: function (event) {
      const data = event.currentTarget.dataset;

      if (!data || !data.path) {
        return;
      }

      if (this.data.selected === Number(data.index)) {
        return;
      }

      wx.switchTab({
        url: data.path
      });
    }
  }
});
