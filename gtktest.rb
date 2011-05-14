require 'gnome2'

class Entry
  def initialize(arg)
    if arg.kind_of? Gtk::TreeIter
      @iter = arg
    elsif arg.kind_of? Gtk::TreeStore
      @iter = arg.append(nil)
    else
      raise "unknown type: #{arg}"
    end
    
    @iter[1] = 400
  end
  
  def text
    @iter[2]
  end
  
  def text=(text)
    @iter[2] = text
  end
  
  def selected
    @iter[0] != nil
  end
  
  def selected=(selected)
    @iter[0] = selected ? 'orange' : nil
    @iter[1] = selected ? 800 : 400
  end
  
  def toggle_selection
    if selected
      self.selected = false
    else
      self.selected = true
    end
  end
end

treestore = Gtk::TreeStore.new(String, Integer, String)

# Append a toplevel row and leave it empty
#parent = treestore.append(nil)

entry = Entry.new(treestore);
entry.text = 'Joe'
entry.selected = true

entry = Entry.new(treestore)
entry.text = 'Jane'

entry = Entry.new(treestore)
entry.text = 'Monica'


view = Gtk::TreeView.new(treestore)
view.selection.mode = Gtk::SELECTION_SINGLE

# Create a renderer and set the 'text' property
renderer = Gtk::CellRendererText.new
renderer.text = "Boooo!"

# Add column using our renderer
col = Gtk::TreeViewColumn.new("First Name", renderer,
                              :background => 0, :weight => 1, :text => 2)
view.append_column(col)

# Create another renderer and set the 'background' property
#renderer = Gtk::CellRendererText.new
#renderer.background = "orange"

# Add column using the second renderer
#col = Gtk::TreeViewColumn.new("Last Name", renderer, :background => 1)
#view.append_column(col)

view.add_events(Gdk::Event::KEY_PRESS)
view.signal_connect("key-press-event") do |w, e|
  p "#{e.keyval}, Gdk::Keyval::GDK_#{Gdk::Keyval.to_name(e.keyval)}"
  
  if e.keyval == Gdk::Keyval::GDK_Insert
    puts "insert!"
    
    selection = view.selection
    iter = selection.selected
    
    entry = Entry.new(iter)
    entry.toggle_selection
  end
end

window = Gtk::Window.new(Gtk::Window::TOPLEVEL)
window.set_default_size(320, 240);

window.signal_connect("delete_event") { Gtk.main_quit; exit! }
#window.add(view)
directory = DirectoryController.new
window.add(directory.view);
window.show_all

Gtk.main