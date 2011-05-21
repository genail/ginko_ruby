require 'gtk2'
require 'gio2'

require 'directory_model'
require 'directory_view'
require 'breadcrumbs_controller'

module Ginko::Directory

  class Controller
    def initialize
      @breadcrumbs = Ginko::Breadcrumbs::Controller.new
      
      @model = Model.new
      @view = View.new(@model, @breadcrumbs.widget)
      
      @view.on_key_pressed do |e|
        cursor = @view.cursor
        
        unless cursor.nil?
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
      
      @breadcrumbs.on_breadcrumb_pressed do |file|
        if file.query_info.directory?
          @model.enter(file)
          @breadcrumbs.file = file
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