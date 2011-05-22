require 'gtk2'
require 'callbacks'
require 'directory/search_bar'

module Ginko::Directory
  class View
    extend Callbacks
    
    attr_reader :widget
    attr_reader :treeview
    attr_reader :search_bar
    
    # when pressed in directory contents
    callback :contents_key_pressed
    
    
    def initialize(context, directory_model, breadcrumbs_widget)
      @context = context
      @directory_model = directory_model
      build_ui(breadcrumbs_widget)
    end
    
    def cursor
      selected = @treeview.selection.selected
      if selected.nil?
        Cursor.new(@treeview)
      else
        Cursor.new(@treeview, @treeview.selection.selected)
      end
    end
    
    def close_searchbar
      @vbox.remove(@search_bar.widget)
      @treeview.grab_focus
    end
    
    #######
    private
    #######
    
    def build_ui(breadcrumbs_widget)
      @vbox = Gtk::VBox.new;
      @widget = @vbox
      
      build_ui_breadcrumbs(breadcrumbs_widget)
      build_ui_directory_contents
      build_ui_searchbar
      
      @widget.show_all
    end
    
    def build_ui_breadcrumbs(breadcrumbs_widget)
      @vbox.pack_start(breadcrumbs_widget, false);
    end
    
    def build_ui_directory_contents
      scrolls = Gtk::ScrolledWindow.new();
      @treeview = Gtk::TreeView.new(@directory_model.store)
      scrolls.add(@treeview)
      
      @vbox.pack_start(scrolls)
      
      @treeview.selection.mode = Gtk::SELECTION_SINGLE
      renderer = Gtk::CellRendererText.new
      col = Gtk::TreeViewColumn.new("Filename", renderer,
                                :background => 0, :weight => 1, :text => 2)
      @treeview.append_column(col)
      
      @treeview.add_events(Gdk::Event::KEY_PRESS)
      @treeview.signal_connect("key-press-event") do |w, e|
        #p "#{e.keyval}, Gdk::Keyval::GDK_#{Gdk::Keyval.to_name(e.keyval)}"
        contents_key_pressed(e)
      end
    end
    
    def build_ui_searchbar
      @search_bar = SearchBar.new
      @context.add_accel(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, 0) do
        @vbox.pack_end(@search_bar.widget, false, false)
        @search_bar.grab_focus
      end
        
    end
    
  end # class

end # module
