require 'gtk2'
require 'pathname'

require 'callbacks'

class BreadcrumbsView
  extend Callbacks
  
  attr_reader :widget
  
  # params: Pathname
  callback :on_breadcrumb_pressed
  # params: Pathname @return Pathname array
  callback :on_content_request
  
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
    
    last_component = nil
    
    @model.path_components.each do |comp|
      add_button("/") { |w, e| display_menu(comp.parent, e) }
      add_button(comp.basename.to_s) { on_breadcrumb_pressed(comp) }
      
      last_component = comp
    end
    
    add_button("/") {| w, e| display_menu(last_component, e) }
    @widget.show_all
  end
  
  def add_button(label, &callback)
    bt = Gtk::Button.new(label)
    bt.relief = Gtk::RELIEF_NONE;
    @hbox.pack_start(bt, false, false)
    
    if callback
      bt.signal_connect("button_press_event", callback)
    end
    
    @added_widgets << bt
    
    return bt
  end
  
  def display_menu(pathname, event)
    if pathname.nil?
      pathname = Pathname.new('/')
    end
    
    menu = Gtk::Menu.new
    
    @model.contents(pathname).each do |entry|
      menu.append(Gtk::MenuItem.new(entry.basename.to_s))
    end
    
    
    menu.show_all
    menu.popup(nil, nil, event.button, event.time)
  end
end
