require 'gio2'

module GLib
  module File
    def directory?
      query_file_type == GLib::File::TYPE_DIRECTORY
    end
  end
end
