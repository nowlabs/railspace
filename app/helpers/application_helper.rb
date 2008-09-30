# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Returns a link for use in layout navigation
  
  def nav_link(attributes = {})
    attributes.symbolize_keys!
    attributes[:action] = "index" unless attributes.has_key?(:action)
    attributes[:text] = "_unset" unless attributes.has_key?(:text)
    link_to_unless_current attributes[:text], :controller => attributes[:controller],
                                              :action => attributes[:action],
                                              :id => nil 
  end
  
  def text_field_for(form, field, size=HTML_TEXT_FIELD_SIZE, maxlength=DB_STRING_MAX_LENGTH)
    label = content_tag("label", "#{field.humanize}:", :for => field)
    form_field = form.text_field field, :size => size, :maxlength => maxlength
    content_tag("div", "#{label}#{form_field}", :class => "form_row")
  end
  
  
end
