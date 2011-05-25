require 'i18n'

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
      @search_bar_open ||= false
      
      if @search_bar_open
        @vbox.remove(@search_bar.widget)
        @search_bar_open = false
      end
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
      @vbox.pack_start(scrolls)
      
      @treeview = Gtk::TreeView.new(@directory_model.store)
      scrolls.add(@treeview)
      
      @treeview.enable_search = false
      
      @treeview.selection.mode = Gtk::SELECTION_SINGLE
      
      add_column(I18n.t("directory_view_filename"), 0,
                 :text => Model::COL_FILENAME)
      add_column(I18n.t("directory_view_extension"), 0,
                 :text => Model::COL_EXT)
      add_column(I18n.t("directory_view_size"), 1,
                 :text => Model::COL_SIZE)
      add_column(I18n.t("directory_view_date"), 0,
                 :text => Model::COL_DATE)
      add_column(I18n.t("directory_view_attr"), 0,
                 :text => Model::COL_ATTR)
      
      @treeview.add_events(Gdk::Event::KEY_PRESS)
      @treeview.signal_connect("key-press-event") do |w, e|
        #p "#{e.keyval}, Gdk::Keyval::GDK_#{Gdk::Keyval.to_name(e.keyval)}"
        contents_key_pressed(e)
      end
    end
    
    def add_column(name, align, properties)
      renderer = Gtk::CellRendererText.new
      renderer.xalign = align
      
      properties[:background] = Model::COL_COLOR
      col = Gtk::TreeViewColumn.new(name, renderer, properties)
      @treeview.append_column(col)
    end
    
    def build_ui_searchbar
      @search_bar = SearchBar.new
      @context.add_accel(Gdk::Keyval::GDK_S, Gdk::Window::CONTROL_MASK, 0) do
        @vbox.pack_end(@search_bar.widget, false, false)
        @search_bar.grab_focus
        @search_bar_open = true
      end
        
    end
    
  end # class

end # module
