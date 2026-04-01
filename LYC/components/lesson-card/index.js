Component({
  options: {
    addGlobalClass: true
  },

  properties: {
    item: {
      type: Object,
      value: {}
    },
    mode: {
      type: String,
      value: 'default'
    }
  },

  methods: {
    handleTap: function () {
      this.triggerEvent('select', this.properties.item);
    }
  }
});
