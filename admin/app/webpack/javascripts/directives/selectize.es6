import Vue from 'vue';
import _ from 'lodash';
import $ from 'jquery';

const opts = {
  select: {
    plugins:      ['remove_button'],
    hideSelected: false
  },
  tag_list: {
    plugins:  ['remove_button', 'drag_drop'],
    create:   true,
    persist:  false,
  },
  relation: {
    plugins:      ['remove_button'],
    hideSelected: false,
    onInitialize: function() {
      let sel     = this,
          options = sel.$input.data('options'),
          items   = sel.$input.data('items');
      _.each(options, o => sel.addOption(o));
      if ( _.isArray(items) ) {
        _.each(items, i => sel.addItem(i));
      } else {
        sel.addItem(items);
      }
      const field = this.$input[0].name
      this.$input.data('field', field)
      $("[name='"+field+"']").remove()
    },
    // PushType by default will store relationships as just ids, but we want to
    // store them as objects. This function appends additional inputs in order
    // to pass the value as an object, onItemRemove removes them
    onItemAdd: function(id, $item) {
      const input = this.$input
      const fieldName = input.data('field') || input[0].name // May not have been set yet
      const options = this.$input.data('options').reduce((acc, val) => (acc[val.value] = val, acc), {});
      const html = ['value', 'type', 'model'].map(field => {
        const value = options[id][field]
        const name = field == 'value' ? 'id' : field
        return "<input class='"+id+"-set relation-input' type='hidden' name='"+fieldName+"["+ name +"]' value='"+value+"' />"
      })
      input.before(html.join(''))
    },
    onItemRemove: function(value) {
      $("."+value+"-set").remove()
    },
    onClear: function(value) {
      $(".relation-input").remove()
    },
    render: {
      option: function(item, esc) {
        let pre = item.depth > 0 ? '- '.repeat(item.depth) : '';
        return `<div class="option">${ pre }${ esc(item.text) }</div>`;
      }
    }
  }
}

export default Vue.directive('selectize', {
  params: ['selectize-kind'],
  bind: function() {
    $(this.el).selectize(opts[this.params.selectizeKind]);
  }
})
