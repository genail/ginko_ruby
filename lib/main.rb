module Ginko
end

require 'directory/controller'

module Ginko
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_default_size(320, 240);
  
  window.signal_connect("delete_event") { Gtk.main_quit; exit! }
  directory = Directory::Controller.new
  window.add(directory.widget);
  window.show_all
  
  Gtk.main
end