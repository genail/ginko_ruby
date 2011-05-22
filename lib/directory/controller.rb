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
        
        if cursor.visible?
          case e.keyval
          when Gdk::Keyval::GDK_Insert
            @model.toggle_selection(cursor.iter)
            cursor.move_down
            
          when Gdk::Keyval::GDK_Return
            iter = cursor.iter
            file = @model.iter_to_file(iter)
            
            if file.query_info.directory?
              @model.enter(file)
              @breadcrumbs.file = file
            else
              launch(file)
            end
          
          when Gdk::Keyval::GDK_BackSpace
            file = @model.leave
            @breadcrumbs.file = file
          end
        end
      end
    end
    
    def init_breadcrumbs
      @breadcrumbs.on_breadcrumb_pressed do |file|
        if file.query_info.directory?
          @model.enter(file)
          @breadcrumbs.file = file
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
              @model.search_filter = nil
              @model.enter(cursor)
              
              @view.close_searchbar
            end
            
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
    
    def launch(file)
      content_type = file.query_info.content_type
      apps_all = GLib::AppInfo::get_all_for_type(content_type)
      apps_all.each { |a| p a.name }
      
      default_app = GLib::AppInfo::get_default_for_type(content_type)
      p "default: #{default_app.name}"
    end
    
  end # class

end # module