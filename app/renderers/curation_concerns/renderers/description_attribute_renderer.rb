module CurationConcerns
  module Renderers
    class DescriptionAttributeRenderer < LinkedAttributeRenderer

      def render
        markup = ''

        return markup if !values.present? && !options[:include_empty]
        markup << %(<dt>#{label}</dt>\n)

        attributes = microdata_object_attributes(field).merge(class: "attribute #{field}")
        all_values = Array(values)

        if(all_values.length == 1)
          markup << "<dd#{html_attributes(attributes)}>#{attribute_value_to_html(all_values.first.to_s)}</dd>"
        else
          markup << "<dd#{html_attributes(attributes)}>\n<ul>"
          all_values.each do |value|
            markup << "<li>#{attribute_value_to_html(value.to_s)}</li>\n"
          end
          markup << "</ul>\n</dd>\n"
        end

        markup.html_safe
      end


      private

      def li_value(value)
        if(@options[:linked])
          link_to(ERB::Util.h(value), search_path(value))
        else
          auto_link(ERB::Util.h(value))
        end
      end
    end
  end
end
