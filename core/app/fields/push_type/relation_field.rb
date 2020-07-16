module PushType
  class RelationField < PushType::FieldType

    options template: 'relation'

    def initialize(*args)
      super
      raise ArgumentError, 'Relation field names must end with suffix `_id` or `_ids`.' unless relation_name
    end

    def json_primitive
       multiple? ? :array : super
    end

    def label
      super || relation_name.humanize
    end

    def html_options
      super.merge(multiple: multiple?)
    end

    def choices
      if relation_items.is_a? Hash
        flatten_tree(relation_items)
      else
        relation_items.map { |item| item_hash(item) }
      end
    end

    def relation_id
      @relation_id ||= begin
        value = json_value
        if value.is_a?(String)
          value = JSON.parse(value.gsub("'", '"').gsub('=>', ':')) if value.strip[0] == '{'
        end
        value.is_a?(Hash) ? value['id'] : value
      end
    end

    def relation_name
      @relation_name ||= (rel = name.to_s.gsub!(/_ids?$/, '')) && (rel && multiple? ? rel.pluralize : rel)
    end

    def relation_class
      @relation_class ||= (@opts[:to] || relation_name.singularize).to_s.classify.constantize
    end

    def relation_items
      @relation_items ||= begin
        if @opts[:scope].respond_to? :call
          relation_class.instance_exec(&@opts[:scope])
        else
          relation_class.all
        end
      end
    end

    def json_value
      # If the field is stored as an object then it will be returned as [name, value]
      if model.field_store.is_a?(Array)
        model.field_store[1]
      else
        model.field_store.try(:[], name.to_s)
      end
    end

    private

    def defaults
      super.merge({
        label:    nil,
        mapping:  { value: :id, text: :title },
      })
    end

    def item_hash(item, d = 0)
      {
        value:  item.send(@opts[:mapping][:value]),
        text:   item.send(@opts[:mapping][:text]),
        depth:  d,
      }
    end

    def flatten_tree(hash_tree, d = 0)
      hash_tree.flat_map do |parent, children|
        [
          item_hash(parent, d),
          flatten_tree(children, d+1)
        ]
      end.flatten
    end

    on_instance do |object, field|
      object.class_eval do
        define_method(field.relation_name.to_sym) do
          return if relation_id.blank?

          if field.multiple?
            field.relation_class.where(id: field.relation_id)
          else
            field.relation_class.find_by_id(field.relation_id)
          end
        end unless method_defined?(field.relation_name.to_sym)
      end
    end

  end
end
