require 'gtk2'

require 'directory_model'
require 'directory_view'
require 'breadcrumbs_model'
require 'breadcrumbs_view'

class DirectoryController
  def initialize
    @bc_model = BreadcrumbsModel.new
    @bc_view = BreadcrumbsView.new(@bc_model)
    
    @model = DirectoryModel.new
    @view = DirectoryView.new(@model, @bc_view.widget)
    
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
          @bc_model.path = path
        end
      end
    end
  end
  
  def widget
    @view.widget
  end
end

