require 'test/unit'
require 'mk4rb'

# These tests are adapted from :
#// tbasic1.cpp -- Regression test program, basic tests part 1
#// $Id: tbasic1.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Basic1_Test < Test::Unit::TestCase

  def test_b00_should_fail
    assert !false
  end

  def test_b02_Int_property
    r1 = Metakit::Row.new
    p1 = Metakit::IntProp.new "p1"

    p1.set r1, 1234567890
    x1 = p1.get(r1)
    assert_equal 1234567890, x1

    p1.set r1, 321456789
    assert_equal 321456789, p1.get(r1)
  end

  def test_b03_Float_property
    r1 = Metakit::Row.new
    p1 = Metakit::FloatProp.new "p1"

    p1.set r1, 123.456
    x1 = p1.get r1

    assert_in_delta 123.456, x1, 0.00001
  end

  def test_b04_String_property
    r1 = Metakit::Row.new
    p1 = Metakit::StringProp.new "p1"

    p1.set r1, "abc"
    assert_equal "abc", p1.get(r1)

    p1.set r1, "xyz"
    assert_equal "xyz", p1.get(r1)
  end

  def test_b05_View_property
    v1 = Metakit::View.new
    r1 = Metakit::Row.new

    p1 = Metakit::ViewProp.new "p1"
    p1.set r1, v1

    x1 = p1.get r1
    # compare cursors to make sure this is the same sequence
    assert_equal x1.get_at(0), v1.get_at(0)
  end

  def test_b06_View_construction
    p1 = Metakit::IntProp.new "p1"
    p2 = Metakit::IntProp.new "p2"
    p3 = Metakit::IntProp.new "p3"

    i1 = Metakit::IntProp.new "i1"
    i2 = Metakit::IntProp.new "i2"
    i3 = Metakit::IntProp.new "i3"

    # comma style from c++
    v1 = p1.comma(p3).comma(p2)
    assert_equal 0, v1.find_property(p1.get_id)
    assert_equal 2, v1.find_property(p2.get_id)
    assert_equal 1, v1.find_property(p3.get_id)
    
    # rubyesque style
    v1 = Metakit::View[i1, i3, i2]
    assert_equal 0, v1.find_property(i1.get_id)
    assert_equal 2, v1.find_property(i2.get_id)
    assert_equal 1, v1.find_property(i3.get_id)
  end

  def test_b07_Row_manipulation
    p1, p2 = Metakit::StringProp[:p1, :p2]
    p3     = Metakit::IntProp.new "p3"
    r1     = Metakit::Row.new
    
    p1.set r1, "look at this"
    x1 = p1.get r1
    assert_equal "look at this", x1
    
    r1 = p1["what's in a"] + p2["name..."]
    
    t = p2.get(r1)
    p1.set r1, t + p1.get(r1)
    p2.set r1, p1.get(r1)
    
    x2 = p1.get(r1) # // 2000-03-16, store as c4_String
    assert_equal "name...what's in a", x2
    
    #// the above change avoids an evaluation order issue in assert below
    assert_equal x2, p2.get(r1)
    p3.set r1, 12345
    p3.set r1, p3.get(r1) + 123

    x3 = p3.get(r1)
    assert_equal x3, 12345 + 123
  end

  def test_b08_Row_expressions
    p1, p2 = Metakit::StringProp[:p1, :p2]
    p3     = Metakit::IntProp.new "p3"

    r1     = Metakit::Row.new
    v1     = Metakit::View[p1, p2, p3]
    v1.set_size 5
    
    r1 = v1[1];
    v1[2] = v1[1];
    v1[3] = r1;
    v1[4] = v1[4];
    r1 = r1
  end

  def test_b09_View_manipulation
    p1, p2 = Metakit::StringProp[:p1, :p2]
    r1     = p1["One"] + p2["Two"]
    r2     = Metakit::Row.new

    v1     = Metakit::View.new
    v1.add(r1)
    v1.add(r2)
    v1.add(r1)
    
    assert_equal 3, v1.get_size
    assert_equal v1[0], r1
    assert_equal v1[1], r2
    assert_equal v1[2], r1

    v1.remove_at 1, 1

    assert_equal 2, v1.get_size
    assert_equal v1[0], r1
    assert_equal v1[0], v1[1]
  end

  def test_b10_View_sorting
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new 
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);

    v2 = v1.sort
    assert_equal v2.get_size, 6
    assert_equal p1.get(v2[0]), 111
    assert_equal p1.get(v2[1]), 123
    assert_equal p1.get(v2[2]), 222
    assert_equal p1.get(v2[3]), 234
    assert_equal p1.get(v2[4]), 333
    assert_equal p1.get(v2[5]), 345
  end

  def test_b11_View_selection
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new
    v1.add p1[111]
    v1.add p1[222]
    v1.add p1[333]
    v1.add p1[345]
    v1.add p1[234]
    v1.add p1[123]
    
    v2 = v1.select_range p1[200], p1[333]

    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])
  end

  def test_b12_Add_after_remove
    p1 = Metakit::StringProp.new "p1"
    v1 = Metakit::View.new

    v1.add(p1["abc"])
    assert 1, v1.get_size

    v1.remove_at(0)
    assert_equal 0, v1.get_size

    v1.add(p1["def"])
    assert_equal 1, v1.get_size
  end

  def test_b13_Clear_view_entry
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new

    v1.add p1[123]
    assert_equal 1, v1.get_size
    assert_equal 123, p1.get(v1[0])

    v1[0] = Metakit::Row.new
    assert_equal 1, v1.get_size
    assert_equal 0, p1.get(v1[0])
  end

  def test_b14_Empty_view_outlives_temp_storage
    v1 = Metakit::View.new
    s1 = Metakit::Storage.default_new

    v1 = s1.get_as "a[p1:I,p2:S]"
  end

  def test_b15_View_outlives_temp_storage
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new

    s1 = Metakit::Storage.default_new
    v1 = s1.get_as "a[p1:I,p2:S]"
    v1.add p1[123]
    s1.close!

    #     // 19990916 - semantics changed, view now 1 row, but 0 props
    assert_equal 1, v1.get_size
    assert_equal 0, v1.num_properties
  end

  def test_b16_View_outlives_cleared_temp_storage
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new

    Metakit::Storage.create {|s1|
      v1 = s1.get_as "a[p1:I,p2:S]"
      v1.add(p1[123])
      v1.remove_all
    }
    
    assert_equal v1.get_size, 0
    v1.add(p1[123])
    assert_equal v1.get_size, 1
    assert_equal p1.get(v1[0]), 123
  end

  def test_b17_Double_property
    r1 = Metakit::Row.new
    p1 = Metakit::DoubleProp.new "p1"

    p1.set r1, 1234.5678
    x1 = p1.get(r1)

    assert_in_delta x1, 1234.5678, 0.00001
  end

  def test_b18_SetAtGrow_usage
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new

    v1.set_at_grow(3, p1[333])
    v1.set_at_grow(1, p1[111])
    v1.set_at_grow(5, p1[555])

    assert_equal v1.get_size, 6
    assert_equal p1.get(v1[1]), 111
    assert_equal p1.get(v1[3]), 333
    assert_equal p1.get(v1[5]), 555
  end

  def test_b19_Bytes_property
    r1 = Metakit::Row.new
    p1 = Metakit::BytesProp.new("p1");
    x1 = Metakit::Bytes.new("hi!", 3)

    p1.set r1, x1;
    x2 = p1.get(r1)
    assert_equal x1, x2
  end
end
