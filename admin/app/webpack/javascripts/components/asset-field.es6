import Vue from 'vue';
import AssetModal from './asset-modal.vue';

export default Vue.component('asset-field', {

  props: {
    asset: {
      coerce: (val) => JSON.parse(val)
    }
  },

  data: function() {
    return {
      uid: `asset-${ Math.uid() }`
    }
  },

  ready: function() {
    if (window.fndtnInit) {
      setTimeout(() => $(this.$el).trigger('init.fndtn'), 100);
    }
  },

  computed: {
    assetId: function() { return this.asset ? this.asset.id : null; },
    assetSize: function() { return this.asset ? this.asset.file_size : null; },
    assetName: function() { return this.asset ? this.asset.file_name : null; } ,
    assetMimeType: function() { return this.asset ? this.asset.mime_type : null; },
    assetUrl: function() { return this.asset ? this.asset.url : null; },
    assetKind: function() { return this.asset ? this.asset.kind : null; },
  },

  methods: {
    selectAsset: function(asset) {
      this.asset = asset;
    },
    deselectAsset: function() {
      this.asset = null;
    }
  },

  components: {
    'asset-modal': AssetModal
  }

})
