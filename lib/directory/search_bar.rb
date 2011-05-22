require 'gtk2'

require 'callbacks'

module Ginko::Directory
  class SearchBar
    extend Callbacks
    
    attr_reader :widget
    
    callback :phase_changed
    callback :key_pressed
    
    def initialize
      @widget = hbox = Gtk::HBox.new
      @entry = Gtk::Entry.new
      hbox.pack_start(@entry)
      
      @entry.signal_connect("changed") { phase_changed(@entry.text) }
      @entry.signal_connect("key-press-event") { |w, e| key_pressed(e) }
      
      @widget.show_all
    end
    
    def grab_focus
      @entry.grab_focus
    end
  end
end
