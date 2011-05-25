require 'test/unit'

module Ginko
end

require 'format/size_format'

module Ginko::Format
  class TestSizeFormat < Test::Unit::TestCase
    def setup
      @format = SizeFormat.new
    end
    
    def test_format_separate
      # this is default method
      assert_equal("0", @format.format(0))
      assert_equal("1", @format.format(1))
      assert_equal("12", @format.format(12))
      assert_equal("123", @format.format(123))
      assert_equal("1 234", @format.format(1234))
      assert_equal("12 345", @format.format(12345))
      assert_equal("123 456", @format.format(123456))
      assert_equal("123 456 789", @format.format(123456789))
    end
    
    def test_format_human_readable
      @format.method = SizeFormat::METHOD_HUMAN_READABLE
      assert_equal("0 B", @format.format(0))
      assert_equal("512 B", @format.format(512))
      assert_equal("1023 B", @format.format(1023))
      assert_equal("1.0 K", @format.format(1024))
      assert_equal("1.5 M", @format.format(1572864))
    end
  end
end
