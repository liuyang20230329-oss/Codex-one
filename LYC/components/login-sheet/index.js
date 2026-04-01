Component({
  properties: {
    visible: {
      type: Boolean,
      value: false
    },
    title: {
      type: String,
      value: ''
    },
    body: {
      type: String,
      value: ''
    },
    primaryText: {
      type: String,
      value: '微信登录继续'
    },
    secondaryText: {
      type: String,
      value: '稍后再说'
    }
  },

  methods: {
    handleMaskTap: function () {
      this.triggerEvent('close');
    },

    handleConfirm: function () {
      this.triggerEvent('confirm');
    },

    handleCancel: function () {
      this.triggerEvent('cancel');
    }
  }
});
