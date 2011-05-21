require 'callbacks'
require 'breadcrumbs/model'
require 'breadcrumbs/view'

module Ginko::Breadcrumbs

  class Controller
    extend Callbacks
    
    # params: GLib::File
    callback :on_breadcrumb_pressed
    
    def initialize
      @model = Model.new
      @view = View.new(@model)
      
      @view.on_breadcrumb_pressed { |p| on_breadcrumb_pressed(p) }
    end
    
    def widget
      @view.widget
    end
    
    def file=(file)
      @model.file = file
    end
    
  end # class

end # module
