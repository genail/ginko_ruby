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
      if e.keyval == Gdk::Keyval::GDK_Insert
        cursor = @view.cursor
        unless cursor.nil?
          @model.toggle_selection(cursor.iter)
          cursor.move_down
        end
      end
    end
  end
  
  def widget
    @view.widget
  end
end

