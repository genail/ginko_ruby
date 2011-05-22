require 'gtk2'
require 'gio2'

require 'directory/model'
require 'directory/view'
require 'directory/cursor'
require 'breadcrumbs/controller'

module Ginko::Directory

  class Controller
    def initialize(context)
      @breadcrumbs = Ginko::Breadcrumbs::Controller.new(context)
      
      @model = Model.new
      @view = View.new(context, @model, @breadcrumbs.widget)
      
      init_contents
      init_breadcrumbs
      init_search_bar
    end
    
    def init_contents
      @view.contents_key_pressed do |e|
        cursor = @view.cursor
        
        case e.keyval
        when Gdk::Keyval::GDK_Insert
          if cursor.visible?
            @model.toggle_selection(cursor.iter)
            cursor.move_down
          end
          
        when Gdk::Keyval::GDK_Return
          if cursor.visible?
            iter = cursor.iter
            file = @model.iter_to_file(iter)
            
            if file.query_info.directory?
              enter(file)
              
            else
              launch(file)
            end
          end
        
        when Gdk::Keyval::GDK_BackSpace
          file = @model.leave
          @breadcrumbs.file = file
          @view.cursor.set_on_first
        end
      end
    end
    
    def init_breadcrumbs
      @breadcrumbs.on_breadcrumb_pressed do |file|
        if file.query_info.directory?
          enter(file)
        end
      end
    end
    
    def init_search_bar
      @view.search_bar.phase_changed do |text|
        @model.search_filter = text
        @model.refilter
        
        cursor = @view.cursor
        unless cursor.visible?
          cursor.set_on_first
        end
      end
      
      @view.search_bar.key_pressed do |e|
        case e.keyval
          when Gdk::Keyval::GDK_Return
            cursor = @view.cursor
            if cursor.visible?
              enter(cursor)
            end
            
          when Gdk::Keyval::GDK_Escape
            cancel_searchbar
            
          when Gdk::Keyval::GDK_Up
            @view.treeview.grab_focus
            @view.cursor.move_up
          when Gdk::Keyval::GDK_Down
            @view.treeview.grab_focus
            @view.cursor.move_down
        end
      end
    end
    
    def widget
      @view.widget
    end
    
    #######
    private
    #######
    
    def enter(cursor_or_file)
      if cursor_or_file.kind_of? Cursor
        file = @model.iter_to_file(cursor_or_file.iter)
      else
        file = cursor_or_file
      end
      
      close_searchbar
      
      @model.enter(file)
      @breadcrumbs.file = file
      @view.cursor.set_on_first
    end
    
    def close_searchbar
      @model.search_filter = nil
      @view.close_searchbar
      @view.treeview.grab_focus
    end
    
    def cancel_searchbar
      close_searchbar
      @model.refilter
    end
    
    def launch(file)
      content_type = file.query_info.content_type
      apps_all = GLib::AppInfo::get_all_for_type(content_type)
      apps_all.each { |a| p a.name }
      
      default_app = GLib::AppInfo::get_default_for_type(content_type)
      p "default: #{default_app.name}"
    end
    
  end # class

end # module