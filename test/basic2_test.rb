require 'test/unit'
require 'mk4rb'

# These tests are adapted from :
#// tbasic2.cpp -- Regression test program, basic tests part 2
#// $Id: tbasic2.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Basic2_Test < Test::Unit::TestCase
  
  def test_b20_Search_sorted_view
    p1 = Metakit::IntProp.new "p1"
    p2 = Metakit::StringProp.new "p2"
    v1 = Metakit::View.new
    v1.add(p1[111] + p2["one"]);
    v1.add(p1[222] + p2["two"]);
    v1.add(p1[333] + p2["three"]);
    v1.add(p1[345] + p2["four"]);
    v1.add(p1[234] + p2["five"]);
    v1.add(p1[123] + p2["six"]);

    v2 = v1.sort
    assert_equal v2.get_size, 6
    assert_equal p1.get(v2[0]), 111
    assert_equal p1.get(v2[1]), 123
    assert_equal p1.get(v2[2]), 222
    assert_equal p1.get(v2[3]), 234
    assert_equal p1.get(v2[4]), 333
    assert_equal p1.get(v2[5]), 345
    assert_equal v2.search(p1[123]), 1
    assert_equal v2.search(p1[100]), 0
    assert_equal v2.search(p1[200]), 2
    assert_equal v2.search(p1[400]), 6

    v3 = v1.sort_on(p2.to_view);
    
    assert_equal v3.get_size, 6
    assert_equal p1.get(v3[0]), 234
    assert_equal p1.get(v3[1]), 345
    assert_equal p1.get(v3[2]), 111
    assert_equal p1.get(v3[3]), 123
    assert_equal p1.get(v3[4]), 333
    assert_equal p1.get(v3[5]), 222
    
    assert_equal v3.search(p2["six"]), 3
    assert_equal v3.search(p2["aha"]), 0
    assert_equal v3.search(p2["gee"]), 2
    assert_equal v3.search(p2["wow"]), 6

    v4 = v1.sort_on_reverse(p2.to_view, p2.to_view)
    
    assert_equal v4.get_size, 6
    assert_equal p1.get(v4[0]), 222
    assert_equal p1.get(v4[1]), 333
    assert_equal p1.get(v4[2]), 123
    assert_equal p1.get(v4[3]), 111
    assert_equal p1.get(v4[4]), 345
    assert_equal p1.get(v4[5]), 234
    assert_equal v4.search(p2["six"]), 2
    assert_equal v4.search(p2["aha"]), 6
    assert_equal v4.search(p2["gee"]), 4
    assert_equal v4.search(p2["wow"]), 0
  end

  def test_b21_Memo_property
    r1 = Metakit::Row.new
    p1 = Metakit::BytesProp.new "p1"
    x1 = Metakit::Bytes.new "hi!", 3

    p1.set r1, x1;
    x2 = p1.get(r1);
    assert_equal x1, x2
  end

  def test_b22_Stored_view_references
    p1 = Metakit::ViewProp.new "p1"
    v1 = Metakit::View.new

    v1.add(p1[Metakit::View.new])

    # // this works
    n = p1.get(v1[0]).get_size
    assert_equal n, 0
  end

  def test_b23_Sort_comparison_fix
    p1 = Metakit::DoubleProp.new "p1"
    v1 = Metakit::View.new

    100.times do |i|
      v1.add p1[99-i]
    end

    v2 = v1.sort
    assert_equal v2.get_size, 100

    100.times {|j|
      assert_equal p1.get(v1[j]), 99-j
      assert_equal p1.get(v2[j]), j
    }
  end

  def test_b24_Custom_view_comparisons
    p1 = Metakit::IntProp.new "p1"
    p2 = Metakit::FloatProp.new "p2"
    p3 = Metakit::DoubleProp.new "p3"
    p4 = Metakit::IntProp.new "p4"
    v1 = Metakit::View.new 

    v1.add(p1[2] + p2[2] + p3[2]);
    v1.add(p1[1] + p2[1] + p3[1]);
    v1.add(p1[3] + p2[3] + p3[3]);
    assert_equal 3, v1.get_size
    assert p1.get(v1[0]).to_i > p1.get(v1[1]).to_i
    assert p2.get(v1[0]).to_f > p2.get(v1[1]).to_f
    assert p3.get(v1[0]).to_f > p3.get(v1[1]).to_f
    assert p1.get(v1[0]).to_i < p1.get(v1[2]).to_i
    assert p2.get(v1[0]).to_f < p2.get(v1[2]).to_f
    assert p3.get(v1[0]).to_f < p3.get(v1[2]).to_f

    v2 = v1.unique
    assert_equal 3, v2.get_size
    assert p1.get(v2[0]).to_i != p1.get(v2[1]).to_i
    assert p2.get(v2[0]).to_f != p2.get(v2[1]).to_f
    assert p3.get(v2[0]).to_f != p3.get(v2[1]).to_f
    assert p1.get(v2[0]).to_i != p1.get(v2[2]).to_i
    assert p2.get(v2[0]).to_f != p2.get(v2[2]).to_f
    assert p3.get(v2[0]).to_f != p3.get(v2[2]).to_f

    v1.add(p1[2] + p2[2] + p3[2]);
    v1.add(p1[1] + p2[1] + p3[1]);
    v1.add(p1[3] + p2[3] + p3[3]);

    v3 = v1.unique
    assert_equal 3, v3.get_size
    assert p1.get(v3[0]).to_i != p1.get(v3[1]).to_i
    assert p2.get(v3[0]).to_f != p2.get(v3[1]).to_f
    assert p3.get(v3[0]).to_f != p3.get(v3[1]).to_f
    assert p1.get(v3[0]).to_i != p1.get(v3[2]).to_i
    assert p2.get(v3[0]).to_f != p2.get(v3[2]).to_f
    assert p3.get(v3[0]).to_f != p3.get(v3[2]).to_f

    v4 = v1.counts(p1.to_view, p4);
    assert_equal 3, v4.get_size

    v5 = v1.counts(p2.to_view, p4);
    assert_equal 3, v5.get_size

    v6 = v1.counts(p3.to_view, p4);
    assert_equal 3, v6.get_size
  end

  def test_b25_Copy_row_from_derived
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new 

    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);

    v2 = v1.select(p1[222]);
    assert_equal 1, v2.get_size
    assert_equal 222, p1.get(v2[0])

    r = v2[0]
    assert_equal 222, p1.get(r) # // 1.9g: failed because SetAt did not remap
  end

  def test_b26_Partial_memo_field_access
    p1 = Metakit::BytesProp.new("p1");
    v1 = Metakit::View.new
    v1.add(p1[Metakit::Bytes.new("12345", 5)]);
    assert_equal 1, v1.get_size

    buf = p1.get(v1[0])
    assert_equal 5, buf.size
    assert_equal buf, Metakit::Bytes.new("12345", 5)
    
    buf = p1.ref(v1[0]).access(1, 3);
    assert_equal buf, Metakit::Bytes.new("234", 3)

    p1.ref(v1[0]).modify(Metakit::Bytes.new("ab", 2), 2, 0);
    buf = p1.get(v1[0]);
    assert_equal buf, Metakit::Bytes.new("12ab5", 5)

    p1.ref(v1[0]).modify(Metakit::Bytes.new("ABC", 3), 1, 2);
    buf = p1.get(v1[0]);
    assert_equal buf, Metakit::Bytes.new("1ABCab5", 7)

    p1.ref(v1[0]).modify(Metakit::Bytes.new("xyz", 3), 2,  - 2);
    buf = p1.get(v1[0]);
    assert_equal buf, Metakit::Bytes.new("1Axyz", 5)

    p1.ref(v1[0]).modify(Metakit::Bytes.new("3456", 4), 4, 0);
    buf = p1.get(v1[0]);
    assert_equal buf, Metakit::Bytes.new("1Axy3456", 8)
  end

  def test_b27_Copy_value_to_another_row
    p1 = Metakit::StringProp.new "p1"
    v1 = Metakit::View.new
    v1.set_size 2, 2
    p1.set v1[1], "abc"

    assert_equal "", p1.get(v1[0])
    assert_equal "abc", p1.get(v1[1])

    p1.set v1[0], p1.get(v1[1])
    assert_equal "abc", p1.get(v1[0])
  end
end
