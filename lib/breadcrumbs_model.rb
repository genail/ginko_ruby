require 'gio2'
require 'callbacks'

require 'preconditions'

class BreadcrumbsModel
  extend Callbacks
  include Preconditions
  
  callback :on_file_changed
  
  def initialize
    @file = GLib::File.new_for_path("/")
  end
  
  def file=(file)
    check_argument(!file.nil?)
    
    @file = file
    on_file_changed
  end
  
  attr_reader :file
  
  def path_components
    components = []
    
    dir = @file
    while dir.has_parent?(nil)
      components << dir
      
      dir = dir.parent
    end
    
    components.reverse
  end
  
  def contents(file)
    check_argument(file.kind_of? GLib::File)
    c = []
    
    file.each do |fileinfo|
      c << file.get_child(fileinfo.name)
    end
    
    c.sort { |a, b| a.basename <=> b.basename }
  end
  
end
