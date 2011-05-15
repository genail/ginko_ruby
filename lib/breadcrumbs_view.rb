require 'gtk2'

require 'callbacks'

class BreadcrumbsView
  extend Callbacks
  
  attr_reader :widget
  
  # params: Pathname
  callback :on_breadcrumb_pressed
  
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
    @added_widgets.clear
    
    @model.path_components.each do |comp|
      add_button("/")
      add_button(comp.basename.to_s) { on_breadcrumb_pressed(comp) }
    end
    
    add_button("/")
    @widget.show_all
  end
  
  def add_button(label, &callback)
    bt = Gtk::Button.new(label)
    bt.relief = Gtk::RELIEF_NONE;
    @hbox.pack_start(bt, false, false)
    
    if callback
      bt.signal_connect("clicked", &callback)
    end
    
    @added_widgets << bt
    
    return bt
  end
end
