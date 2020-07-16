module PushType
  class AssetField < RelationField

    options template: 'asset'

    def relation_class
      PushType::Asset
    end

    on_instance do |object, field|
      object.class_eval do
        define_method(field.relation_name.to_sym) do
          value = field.json_value
          if value.is_a?(String)
            value = JSON.parse(value.gsub("'", '"').gsub('=>', ':')) if value.strip[0] == '{'
          end
          value = value.is_a?(Hash) ? value['id'] : value
          field.relation_class.not_trash.find_by_id(value) unless value.blank?
        end unless method_defined?(field.relation_name.to_sym)
      end
    end

  end
end
