require 'gtk2'

require 'callbacks'
require 'breadcrumbs/model'
require 'breadcrumbs/view'

module Ginko::Breadcrumbs

  class Controller
    extend Callbacks
    
    # params: GLib::File
    callback :on_breadcrumb_pressed
    
    def initialize(context)
      @model = Model.new
      @view = View.new(context, @model)
      
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
