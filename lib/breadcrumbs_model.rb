require 'pathname'
require 'callbacks'

class BreadcrumbsModel
  extend Callbacks
  
  callback :on_path_changed
  
  def initialize
    @path = Pathname.new('/')
  end
  
  def path=(path)
    @path = path
    on_path_changed
  end
  
  attr_reader :path
  
  def path_components
    components = []
    
    dir = @path
    while not dir.root?
      components << dir
      
      dir_s, base_s = dir.split
      dir = Pathname.new(dir_s)
    end
    
    components.reverse
    
  end
  
end
