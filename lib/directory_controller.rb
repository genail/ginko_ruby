require 'gtk2'

require 'directory_model'
require 'directory_view'
require 'breadcrumbs_controller'

class DirectoryController
  def initialize
    @breadcrumbs = BreadcrumbsController.new
    
    @model = DirectoryModel.new
    @view = DirectoryView.new(@model, @breadcrumbs.widget)
    
    @view.on_key_pressed do |e|
      cursor = @view.cursor
      
      unless cursor.nil?
        case e.keyval
        when Gdk::Keyval::GDK_Insert
          @model.toggle_selection(cursor.iter)
          cursor.move_down
          
        when Gdk::Keyval::GDK_Return
          iter = cursor.iter
          path = @model.enter(iter)
          @breadcrumbs.path = path
        
        when Gdk::Keyval::GDK_BackSpace
          path = @model.leave
          @breadcrumbs.path = path
        end
      end
    end
    
    @breadcrumbs.on_breadcrumb_pressed do |pathname|
      @model.enter(pathname)
    end
    
  end
  
  def widget
    @view.widget
  end
end

