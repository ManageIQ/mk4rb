require 'mk4rb_test_helper'

# These tests are adapted from :
#// tcusto1.cpp -- Regression test program, custom view tests
#// $Id: tcusto1.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Custo1_Test < MetakitBaseTest

  def test_c01_Slice_forward
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);
    v1.add(p1[456]);
    v1.add(p1[567]);

    v2 = v1.slice(1,  - 1, 2);
    assert_equal 2, v2.get_size
    assert_equal 234, p1.get(v2[0])
    assert_equal 456, p1.get(v2[1])

    v1.add(p1[678]);
    assert_equal 6, v1.get_size
    assert_equal 3, v2.get_size
    assert_equal 678, p1.get(v2[2])
  end

  def test_c02_Slice_backward
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);
    v1.add(p1[456]);
    v1.add(p1[567]);

    v2 = v1.slice(1,  - 1,  - 2);
    assert_equal 2, v2.get_size
    assert_equal 456, p1.get(v2[0])
    assert_equal 234, p1.get(v2[1])

    v1.add(p1[678]);
    assert_equal 6, v1.get_size
    assert_equal 3, v2.get_size
    assert_equal 678, p1.get(v2[0])
    assert_equal 456, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])
  end

  def test_c03_Slice_reverse
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);
    v1.add(p1[456]);
    v1.add(p1[567]);

    v2 = v1.slice(1, 5,  - 1);
    assert_equal 4, v2.get_size
    assert_equal 567, p1.get(v2[0])
    assert_equal 456, p1.get(v2[1])
    assert_equal 345, p1.get(v2[2])
    assert_equal 234, p1.get(v2[3])

    v1.add(p1[678]);
    assert_equal 6, v1.get_size()
    assert_equal 4, v2.get_size()
  end

  def test_c04_Cartesian_product
    p1, p2 = Metakit::IntProp[:p1, :p2]

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);

    v2 = Metakit::View.new
    v2.add(p2[111]);
    v2.add(p2[222]);

    v3 = v1.product(v2);
    assert_equal 6, v3.get_size
    assert_equal 123, p1.get(v3[0])
    assert_equal 111, p2.get(v3[0])
    assert_equal 123, p1.get(v3[1])
    assert_equal 222, p2.get(v3[1])
    assert_equal 234, p1.get(v3[2])
    assert_equal 111, p2.get(v3[2])
    assert_equal 234, p1.get(v3[3])
    assert_equal 222, p2.get(v3[3])
    assert_equal 345, p1.get(v3[4])
    assert_equal 111, p2.get(v3[4])
    assert_equal 345, p1.get(v3[5])
    assert_equal 222, p2.get(v3[5])

    v1.add(p1[456]);
    assert_equal 8, v3.get_size
    v2.add(p2[333]);
    assert_equal 12, v3.get_size
  end

  def test_c05_Remapping
    p1 = Metakit::IntProp.new("p1")

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);

    v2 = Metakit::View.new
    v2.add(p1[2]);
    v2.add(p1[0]);
    v2.add(p1[1]);
    v2.add(p1[0]);

    v3 = v1.remap_with(v2);
    assert_equal 4, v3.get_size
    assert_equal 345, p1.get(v3[0])
    assert_equal 123, p1.get(v3[1])
    assert_equal 234, p1.get(v3[2])
    assert_equal 123, p1.get(v3[3])
  end

  def test_c06_Pairwise_combination
    p1, p2 = Metakit::IntProp[:p1, :p2]

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);

    v2 = Metakit::View.new
    v2.add(p2[111]);
    v2.add(p2[222]);
    v2.add(p2[333]);

    v3 = v1.pair(v2);
    assert_equal 3, v3.get_size
    assert_equal 123, p1.get(v3[0])
    assert_equal 111, p2.get(v3[0])
    assert_equal 234, p1.get(v3[1])
    assert_equal 222, p2.get(v3[1])
    assert_equal 345, p1.get(v3[2])
    assert_equal 333, p2.get(v3[2])
  end

  def test_c07_Concatenate_views
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);

    v2 = Metakit::View.new
    v2.add(p1[111]);
    v2.add(p1[222]);

    v3 = v1.concat(v2);
    assert_equal 5, v3.get_size
    assert_equal 123, p1.get(v3[0])
    assert_equal 234, p1.get(v3[1])
    assert_equal 345, p1.get(v3[2])
    assert_equal 111, p1.get(v3[3])
    assert_equal 222, p1.get(v3[4])
  end

  def test_c08_Rename_property
    p1, p2 = Metakit::IntProp[:p1, :p2]

    v1 = Metakit::View.new
    v1.add(p1[123]);
    v1.add(p1[234]);
    v1.add(p1[345]);

    v2 = v1.rename(p1, p2);
    assert_equal 3, v2.get_size
    assert_equal 123, p2.get(v2[0])
    assert_equal 234, p2.get(v2[1])
    assert_equal 345, p2.get(v2[2])
    assert_equal 0, p1.get(v2[0])
    assert_equal 0, p1.get(v2[1])
    assert_equal 0, p1.get(v2[2])
  end

  def test_c09_GroupBy_operation
    p1 = Metakit::StringProp.new("p1");
    p2 = Metakit::IntProp.new("p2");
    p3 = Metakit::ViewProp.new("p3");

    v1 = Metakit::View.new

    v1.add(p1[""]);
    v1.add(p1["1"] + p2[1]);
    v1.add(p1["12"] + p2[1]);
    v1.add(p1["12"] + p2[2]);
    v1.add(p1["123"] + p2[1]);
    v1.add(p1["123"] + p2[2]);
    v1.add(p1["123"] + p2[3]);

    v2 = v1.group_by(p1, p3);
    assert_equal 4, v2.get_size
    assert_equal "", p1.get(v2[0])
    assert_equal "1", p1.get(v2[1])
    assert_equal "12", p1.get(v2[2])
    assert_equal "123", p1.get(v2[3])

    v3 = p3.get(v2[0]);
    assert_equal 1, v3.get_size
    assert_equal 0, p2.get(v3[0])

    v3 = p3.get(v2[1]);
    assert_equal 1, v3.get_size
    assert_equal 1, p2.get(v3[0])

    v3 = p3.get(v2[2]);
    assert_equal 2, v3.get_size
    assert_equal 1, p2.get(v3[0])
    assert_equal 2, p2.get(v3[1])

    v3 = p3.get(v2[3]);
    assert_equal 3, v3.get_size
    assert_equal 1, p2.get(v3[0])
    assert_equal 2, p2.get(v3[1])
    assert_equal 3, p2.get(v3[2])
  end

  def test_c10_Counts_operation
    p1 = Metakit::StringProp.new("p1");
    p2, p3 = Metakit::IntProp[:p2, :p3]

    v1 = Metakit::View.new 

    v1.add(p1[""]);
    v1.add(p1["1"] + p2[1]);
    v1.add(p1["12"] + p2[1]);
    v1.add(p1["12"] + p2[2]);
    v1.add(p1["123"] + p2[1]);
    v1.add(p1["123"] + p2[2]);
    v1.add(p1["123"] + p2[3]);

    v2 = v1.counts(p1, p3)
    assert_equal 4, v2.get_size
    assert_equal "", p1.get(v2[0])
    assert_equal "1", p1.get(v2[1])
    assert_equal "12", p1.get(v2[2])
    assert_equal "123", p1.get(v2[3])

    assert_equal 0, p2.get(v2[0])
    assert_equal 0, p2.get(v2[1])
    assert_equal 0, p2.get(v2[2])
    assert_equal 0, p2.get(v2[3])

    assert_equal 1, p3.get(v2[0])
    assert_equal 1, p3.get(v2[1])
    assert_equal 2, p3.get(v2[2])
    assert_equal 3, p3.get(v2[3])
  end

end

