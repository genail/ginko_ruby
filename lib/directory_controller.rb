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
            file = @model.enter(iter)
            @breadcrumbs.file = file
          
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
    
  end # class

end # module