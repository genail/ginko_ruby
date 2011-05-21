require 'gtk2'
require 'gio2'
require 'pathname'

require 'callbacks'
require 'preconditions'

module Ginko::Breadcrumbs

  class View
    extend Callbacks
    
    class Completion
      include Preconditions
      extend Callbacks
      
      # args: path_string
      callback :selected
      
      def initialize(entry)
        @comp = Gtk::EntryCompletion.new
        @comp.model = Gtk::ListStore.new(String)
        @comp.set_text_column(0)
        @comp.inline_completion = true
        
        @comp.signal_connect("match-selected") do |s, m, i|
          selected m.get_value(i, 0);
        end
        
        entry.set_completion(@comp)
      end
      
      def add(value)
        iter = @comp.model.append
        iter[0] = value
      end
      
      def clear
        @comp.model.clear
      end
      
      def rebuild(pathname)
        check_argument(pathname.kind_of? Pathname)
        clear
        
        if not pathname.exist?
          return
        end
        
        pathname.each_entry do |entry|
          basename = entry.basename
          unless basename == "." or basename == ".."
            add((pathname + entry).realpath.to_s + "/")
          end
        end
      end
    end
    
    attr_reader :widget
    
    # :buttons or :text
    attr_accessor :mode
    
    # params: File
    callback :on_breadcrumb_pressed
    
    def initialize(breadcrumbs_model)
      @mode = :buttons
      
      @model = breadcrumbs_model
      @model.on_file_changed { refresh }
      
      @added_widgets = []
      
      build_ui
      refresh
    end
    
    #######
    private
    #######
    
    def build_ui
      @hbox = Gtk::HBox.new();
      @widget = @hbox
      
      @toggle_button = Gtk::Button.new("t")
      @hbox.pack_end(@toggle_button, false, false)
      
      @toggle_button.signal_connect("pressed") { toggle_mode }
      
      @entry = Gtk::Entry.new()
      @comp = Completion.new(@entry)
      
      @entry.signal_connect("changed") { refresh_completion }
      @entry.signal_connect("activate") do
        on_breadcrumb_pressed(GLib::File.new_for_path(@entry.text))
      end
      @comp.selected { |path| p path; on_breadcrumb_pressed(GLib::File.new_for_path(path)) }
    end
    
    def toggle_mode
      if @mode == :buttons
        @mode = :text
      elsif @mode == :text
        @mode = :buttons
      else
        raise "unknown mode: #{@mode}"
      end
      
      refresh
    end
    
    def refresh
      @added_widgets.each { |w| @hbox.remove w }
      @added_widgets.clear
      
      unless @entry.parent.nil?
        @hbox.remove(@entry)
      end
      
      if @mode == :buttons
        refresh_buttons_mode
      elsif @mode == :text
        refresh_text_mode
      else
        raise "unknown mode: #{@mode}"
      end
    end
    
    def refresh_buttons_mode
      last_component = nil
      
      @model.path_components.each do |comp|
        add_button("/") { |w, e| display_menu(comp.parent, e) }
        add_button(comp.basename.to_s) { on_breadcrumb_pressed(comp) }
        
        last_component = comp
      end
      
      add_button("/") {| w, e| display_menu(last_component, e) }
      @widget.show_all
    end
    
    def refresh_text_mode
      @hbox.pack_start(@entry)
      @entry.text = @model.path
      @widget.show_all
      
      refresh_completion
    end
    
    def refresh_completion
      if @entry.text.empty?
        return
      end
      
      if @entry.text.end_with? '/'
        new_workdir = @entry.text
      elsif @entry.text.count("/") == 1
        new_workdir = "/"
      else
        new_workdir = @entry.text.split("/")[0..-2].join("/")
      end
      
      unless @comp_workdir == new_workdir
        @comp_workdir = new_workdir
        
        #puts "comp dir changed to #{@comp_workdir}"
        #$stdout.flush
        
        @comp.rebuild(Pathname.new(@comp_workdir))
      end
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
    
    def display_menu(file, event)
      if file.nil?
        file = GLib::File.new_for_path('/')
      end
      
      menu = Gtk::Menu.new
      
      @model.contents(file).each do |entry|
        item = Gtk::MenuItem.new(entry.basename.to_s)
        item.signal_connect("activate") { on_breadcrumb_pressed(entry) }
        menu.append(item)
      end
      
      
      menu.show_all
      menu.popup(nil, nil, event.button, event.time)
    end
  end # class

end # module