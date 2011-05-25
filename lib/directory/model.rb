require 'gio2'
require 'extended/glib_file'

require 'preconditions'
require 'format/size_format'

module Ginko::Directory

  class Model
    include Preconditions
    
    COL_COLOR = 0
    COL_WEIGHT = 1
    COL_FILENAME = 2
    COL_EXT = 3
    COL_SIZE = 4
    COL_DATE = 5
    COL_ATTR = 6
    
    attr_reader :filtered_store
    alias :store :filtered_store
    
    class Entry
      def initialize(arg)
        if arg.kind_of? Gtk::TreeIter
          # existing entry
          @iter = arg
        elsif arg.kind_of? Gtk::ListStore
          # new entry
          @iter = arg.append()
          @iter[COL_WEIGHT] = 400
        else
          raise "unknown type: #{arg.class}"
        end
        
        #if arg.kind_of? Gtk::TreeStore
        #  @iter[COL_WEIGHT] = 400
        #end
      end
      
      def Entry.iter_accessor(name, column_idx)
        class_eval <<-EOF
          def #{name}
            @iter[#{column_idx}]
          end
          
          def #{name}=(arg)
            @iter[#{column_idx}] = arg.to_s
          end
        EOF
      end
      
      iter_accessor :filename, COL_FILENAME
      iter_accessor :ext, COL_EXT
      iter_accessor :size, COL_SIZE
      iter_accessor :date, COL_DATE
      iter_accessor :attr, COL_ATTR
      
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
    
    def initialize(context)
      @context = context
      
      @store = Gtk::ListStore.new(
          String, # color
          Integer, # weight
          String, # filename
          String, # ext
          String, # size
          String, # date
          String # attr
          )
      @filtered_store = Gtk::TreeModelFilter.new(@store)
      
      @filtered_store.set_visible_func do |m, i|
        unless @search_filter.nil?
          entry = Entry.new(i)
          entry.filename != nil &&
          entry.filename.downcase.include?(@search_filter.downcase)
        else
          true
        end
      end
      
      enter(GLib::File.new_for_path("/"))
    end
    
    def toggle_selection(iter)
      entry = Entry.new(unfilter(iter))
      entry.toggle_selection
    end
    
    def iter_to_file(iter)
      check_argument(iter.kind_of? Gtk::TreeIter)
      entry = Entry.new(unfilter(iter))
      @file.get_child(entry.filename)
    end
    
    def enter(place)
      if place.kind_of? Cursor
        place = iter_to_file(place.iter)
      end
      
      enter_file(place)
    end
    
    def leave
      if @file.has_parent?(nil)
        enter(@file.parent)
      end
      
      @file
    end
    
    def search_filter=(search_filter)
      @search_filter = search_filter
    end
    
    def refilter
      @filtered_store.refilter
    end
    
    #######
    private
    #######
    
    def unfilter(iter)
      @filtered_store.convert_iter_to_child_iter(iter)
    end
    
    def enter_file(file)
      check_argument(file.kind_of? GLib::File)
      
      t1 = Time.now
      
      lock
      begin
        
        @store.clear
        raise "not a directory" unless file.directory?
        
        @file = file
        
        size_format = Ginko::Format::SizeFormat.new
        
        file.each do |fileinfo|
          entry = Entry.new(@store)
          entry.filename = fileinfo.display_name
          entry.size = size_format.format(fileinfo.size)
        end
      ensure
        unlock
      end
      
      t2 = Time.now
      @context.log.info "entered #{file.path} in #{t2 - t1}s"
      $stdout.flush
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
