require 'glib2'
require 'pathname'

require 'preconditions'

class DirectoryModel
  include Preconditions
  
  COL_COLOR = 0
  COL_WEIGHT = 1
  COL_FILENAME = 2
  
  attr_reader :store
  
  class Entry
    def initialize(arg)
      if arg.kind_of? Gtk::TreeIter
        # existing entry
        @iter = arg
      elsif arg.kind_of? Gtk::TreeStore
        # new entry
        @iter = arg.append(nil)
        @iter[COL_WEIGHT] = 400
      else
        raise "unknown type: #{arg.class}"
      end
      
      #if arg.kind_of? Gtk::TreeStore
      #  @iter[COL_WEIGHT] = 400
      #end
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
    
    change_directory(Pathname.new('/'))
  end
  
  def toggle_selection(iter)
    entry = Entry.new(iter)
    entry.toggle_selection
  end
  
  def enter(iter)
    entry = Entry.new(iter)
    new_path = Pathname.new(@path.to_s + File::SEPARATOR + entry.filename).realpath
    
    
    if new_path.directory?
      change_directory(new_path)
    end
    
    @path
  end
  
  def change_directory(path)
    lock
    begin
    
      check_argument(path.kind_of? Pathname)
      
      @store.clear
      raise "not a directory" unless path.directory?
      
      @path = path
      
      path.each_entry do |child|
        entry = Entry.new(@store)
        entry.filename = child
      end
    ensure
      unlock
    end
  end
  
  #######
  private
  #######
  
  # locking should be used when editing tree contents
  # not locked editing will be slower and may cause unexpected errors
  def lock
    @store.set_sort_column_id(-2, Gtk::SORT_ASCENDING);
  end
  
  def unlock
    @store.set_sort_func(COL_FILENAME) do |iter1, iter2|
      entry1 = Entry.new(iter1)
      entry2 = Entry.new(iter2)
      
      entry1.filename <=> entry2.filename
    end
    @store.set_sort_column_id(COL_FILENAME, Gtk::SORT_ASCENDING)
  end
end
