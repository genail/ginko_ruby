require 'gtk2'

require 'callbacks'

module Ginko::Directory

  class View
    class Cursor
      attr_reader :iter
      
      def initialize(view, iter)
        @view = view
        @iter = iter
      end
      
      def move_down
        if @iter.next!
          @view.set_cursor(@iter.path, nil, false)
        end
      end
    end
    
    attr_reader :widget
    
    extend Callbacks
    callback :on_key_pressed
    
    def initialize(directory_model, breadcrumbs_widget)
      @directory_model = directory_model
      build_ui(breadcrumbs_widget)
    end
    
    def build_ui(breadcrumbs_widget)
      build_ui_structure(breadcrumbs_widget)
      
      @treeview.selection.mode = Gtk::SELECTION_SINGLE
  
      renderer = Gtk::CellRendererText.new
  
      col = Gtk::TreeViewColumn.new("Filename", renderer,
                                :background => 0, :weight => 1, :text => 2)
      @treeview.append_column(col)
      
      @treeview.add_events(Gdk::Event::KEY_PRESS)
      @treeview.signal_connect("key-press-event") do |w, e|
        #p "#{e.keyval}, Gdk::Keyval::GDK_#{Gdk::Keyval.to_name(e.keyval)}"
        on_key_pressed(e)
      end
      
      @treeview.show_all
    end
    
    def build_ui_structure(breadcrumbs_widget)
      vbox = Gtk::VBox.new;
      @widget = vbox
      
      vbox.pack_start(breadcrumbs_widget, false);
      
      scrolls = Gtk::ScrolledWindow.new();
      vbox.pack_start(scrolls);
      
      @treeview = Gtk::TreeView.new(@directory_model.store)
      scrolls.add(@treeview)
    end
    
    # TreeIter
    def cursor
      selected = @treeview.selection.selected
      if selected.nil?
        return nil
      else
        return Cursor.new(@treeview, @treeview.selection.selected)
      end
    end
  end # class

end # module
