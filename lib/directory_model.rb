require 'glib2'

class DirectoryModel
  COL_COLOR = 0
  COL_WEIGHT = 1
  COL_FILENAME = 2
  
  attr_reader :store
  
  class Entry
    def initialize(arg)
      if arg.kind_of? Gtk::TreeIter
        @iter = arg
      elsif arg.kind_of? Gtk::TreeStore
        @iter = arg.append(nil)
      else
        raise "unknown type: #{arg.class}"
      end
      
      @iter[COL_WEIGHT] = 400
    end
    
    def filename
      @iter[COL_FILENAME]
    end
    
    def filename=(text)
      @iter[COL_FILENAME] = text
    end
    
    def selected
      @iter[COL_COLOR] != nil
    end
    
    def selected=(selected)
      @iter[COL_COLOR] = selected ? 'orange' : nil
      @iter[COL_WEIGHT] = selected ? 800 : 400
    end
    
    def toggle_selection
      if selected
        self.selected = false
      else
        self.selected = true
      end
    end
  end
  
  def initialize
    @store = Gtk::TreeStore.new(String, Integer, String)
    
    entry = Entry.new(@store)
    entry.filename = "first"
    
    entry = Entry.new(@store)
    entry.filename = "second"
    
    entry = Entry.new(@store)
    entry.filename = "third"
    
    change_directory('/')
  end
  
  def toggle_selection(iter)
    entry = Entry.new(iter)
    entry.toggle_selection
  end
  
  def change_directory(filename)
    @store.clear
    raise "not a directory" unless File.directory? filename
    
    dir = Dir.new(filename)
    dir.each do |child|
      entry = Entry.new(@store)
      entry.filename = child
    end
  end
end
