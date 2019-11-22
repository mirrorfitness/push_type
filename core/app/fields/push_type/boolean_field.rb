module PushType
  class BooleanField < PushType::FieldType

    options json_primitive: :boolean,
            html_options:   { include_hidden: false },
            form_helper: :check_box

    def value
      json_value.to_bool
    end

  end
end
