Component({
  options: {
    addGlobalClass: true
  },

  properties: {
    item: {
      type: Object,
      value: {}
    }
  },

  methods: {
    handleTap: function () {
      this.triggerEvent('select', this.properties.item);
    }
  }
});
