require 'callbacks'
require 'breadcrumbs_model'
require 'breadcrumbs_view'

class BreadcrumbsController
  extend Callbacks
  
  # params: Pathname
  callback :on_breadcrumb_pressed
  
  def initialize
    @model = BreadcrumbsModel.new
    @view = BreadcrumbsView.new(@model)
    
    @view.on_breadcrumb_pressed { |p| on_breadcrumb_pressed(p) }
  end
  
  def widget
    @view.widget
  end
  
  def path=(path)
    @model.path = path
  end
end
