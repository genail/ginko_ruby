#!/usr/bin/env ruby1.9.1
require 'rubygems'

require 'i18n'
I18n.load_path << File.dirname(__FILE__) + "/../locale/en.yml"

module Ginko
end

require 'context'
require 'directory/controller'

module Ginko
  window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
  window.set_default_size(320, 480);
  
  window.signal_connect("delete_event") { Gtk.main_quit; }
  
  context = Context.new
  context.main_window = window
  
  directory = Directory::Controller.new(context)
  window.add(directory.widget);
  window.show_all
  
  Gtk.main
end