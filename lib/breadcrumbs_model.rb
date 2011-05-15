require 'pathname'
require 'callbacks'

require 'preconditions'

class BreadcrumbsModel
  extend Callbacks
  include Preconditions
  
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
  
  def contents(pathname)
    check_argument(pathname.kind_of? Pathname)
    pathname.children.sort { |a, b| a <=> b }
  end
  
end
