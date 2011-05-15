require 'gtk2'

class BreadcrumbsView
  attr_reader :widget
  
  def initialize(breadcrumbs_model)
    @model = breadcrumbs_model
    @model.on_path_changed { refresh }
    
    @added_widgets = []
    
    build_ui
    refresh
  end
  
  def build_ui
    @hbox = Gtk::HBox.new();
    @widget = @hbox
  end
  
  def refresh
    @added_widgets.each { |w| @hbox.remove w }
    @model.path_components.each do |comp|
      add_button(">")
      add_button(comp);
    end
    
    add_button(">")
  end
  
  def add_button(label)
    bt = Gtk::Button.new(label)
    bt.relief = Gtk::RELIEF_NONE;
    @hbox.pack_start(bt, false, false)
    @added_widgets << bt
    
    return bt
  end
end
