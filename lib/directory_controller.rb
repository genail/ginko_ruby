require 'gtk2'

require 'directory_model'
require 'directory_view'

class DirectoryController
  def initialize
    @model = DirectoryModel.new
    @view = DirectoryView.new(@model)
    
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

