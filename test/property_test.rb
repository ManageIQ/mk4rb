require 'test/unit'
require 'mk4rb'

class PropertiesTest < Test::Unit::TestCase
  def test_property_creation
    assert_raise NoMethodError do
      Metakit::Property.new
    end
  end
  
  def test_base_methods
    assert_equal "mid", Metakit::StringProp.new("mid").name
    assert_equal "mpath", Metakit::StringProp.new("mpath").name
    assert_equal "mwidth", Metakit::IntProp.new("mwidth").name
    assert_equal "mheight", Metakit::IntProp.new("mheight").name
    
    assert_equal ?I, Metakit::IntProp.new("dummyInt").metakit_type
    assert_equal ?S, Metakit::StringProp.new("dummyStr").metakit_type
  end
end

