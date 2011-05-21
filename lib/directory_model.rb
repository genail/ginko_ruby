require 'gio2'

require 'preconditions'

module Ginko::Directory

  class Model
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
        @iter[COL_FILENAME] = text.to_s
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
      
      enter(GLib::File.new_for_path("/"))
    end
    
    def toggle_selection(iter)
      entry = Entry.new(iter)
      entry.toggle_selection
    end
    
    def iter_to_file(iter)
      check_argument(iter.kind_of? Gtk::TreeIter)
      entry = Entry.new(iter)
      @file.get_child(entry.filename)
    end
    
    def enter(place)
      if place.kind_of? Gtk::TreeIter
        place = iter_to_file(place)
      end
      
      enter_file(place)
    end
    
    def leave
      if @file.has_parent?(nil)
        enter(@file.parent)
      end
      
      @file
    end
    
    #######
    private
    #######
    
    def enter_file(file)
      check_argument(file.kind_of? GLib::File)
      
      lock
      begin
        
        @store.clear
        raise "not a directory" unless file.query_file_type == GLib::File::TYPE_DIRECTORY
        
        @file = file
        
        file.each do |fileinfo|
          entry = Entry.new(@store)
          entry.filename = fileinfo.display_name
        end
      ensure
        unlock
      end
    end
    
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
  end # class

end # module
