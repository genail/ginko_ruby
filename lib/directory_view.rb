require 'gtk2'

require 'callbacks'

class DirectoryView
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
  
  def initialize(directory_model)
    @directory_model = directory_model
    
    @widget = Gtk::ScrolledWindow.new();
    
    @view = Gtk::TreeView.new(directory_model.store)
    @widget.add(@view)
    
    @view.selection.mode = Gtk::SELECTION_SINGLE

    renderer = Gtk::CellRendererText.new

    col = Gtk::TreeViewColumn.new("Filename", renderer,
                              :background => 0, :weight => 1, :text => 2)
    @view.append_column(col)
    
    @view.add_events(Gdk::Event::KEY_PRESS)
    @view.signal_connect("key-press-event") do |w, e|
      #p "#{e.keyval}, Gdk::Keyval::GDK_#{Gdk::Keyval.to_name(e.keyval)}"
      on_key_pressed(e)
    end
    
    @view.show_all
  end
  
  # TreeIter
  def cursor
    selected = @view.selection.selected
    if selected.nil?
      return nil
    else
      return Cursor.new(@view, @view.selection.selected)
    end
  end
end
