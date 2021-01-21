require 'mk4rb_test_helper'

# These tests are adapted from :
#// tcusto2.cpp -- Regression test program, custom view tests
#// $Id: tcusto2.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Custo1_Test < MetakitBaseTest
  
  def test_c11_Unique_operation
    p1, p2 = Metakit::IntProp[:p1, :p2]

    v1 = Metakit::View.new

    v1.add(p1[1] + p2[11]);
    v1.add(p1[1] + p2[22]);
    v1.add(p1[2] + p2[33]);
    v1.add(p1[2] + p2[33]);
    v1.add(p1[3] + p2[44]);
    v1.add(p1[4] + p2[55]);
    v1.add(p1[4] + p2[55]);
    v1.add(p1[4] + p2[55]);

    v2 = v1.unique();
    assert_equal 5, v2.get_size
    assert_equal 1, p1.get(v2[0])
    assert_equal 1, p1.get(v2[1])
    assert_equal 2, p1.get(v2[2])
    assert_equal 3, p1.get(v2[3])
    assert_equal 4, p1.get(v2[4])

    assert_equal 11, p2.get(v2[0])
    assert_equal 22, p2.get(v2[1])
    assert_equal 33, p2.get(v2[2])
    assert_equal 44, p2.get(v2[3])
    assert_equal 55, p2.get(v2[4])
  end

  def test_c12_Union_operation
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[1]);
    v1.add(p1[2]);
    v1.add(p1[3]);

    v2.add(p1[2]);
    v2.add(p1[3]);
    v2.add(p1[4]);
    v2.add(p1[5]);

    v3 = v1.union(v2);
    assert_equal 5, v3.get_size
    assert_equal 1, p1.get(v3[0])
    assert_equal 2, p1.get(v3[1])
    assert_equal 3, p1.get(v3[2])
    assert_equal 4, p1.get(v3[3])
    assert_equal 5, p1.get(v3[4])
  end

  def test_c13_Intersect_operation
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[1]);
    v1.add(p1[2]);
    v1.add(p1[3]);

    v2.add(p1[2]);
    v2.add(p1[3]);
    v2.add(p1[4]);
    v2.add(p1[5]);

    v3 = v1.intersect(v2);
    assert_equal 2, v3.get_size
    assert_equal 2, p1.get(v3[0])
    assert_equal 3, p1.get(v3[1])
  end

  def test_c14_Different_operation
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[1]);
    v1.add(p1[2]);
    v1.add(p1[3]);

    v2.add(p1[2]);
    v2.add(p1[3]);
    v2.add(p1[4]);
    v2.add(p1[5]);

    v3 = v1.different(v2);
    assert_equal 3, v3.get_size
    assert_equal 1, p1.get(v3[0])
    assert_equal 4, p1.get(v3[1])
    assert_equal 5, p1.get(v3[2])
  end

  def test_c15_Minus_operation
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[1]);
    v1.add(p1[2]);
    v1.add(p1[3]);

    v2.add(p1[2]);
    v2.add(p1[3]);
    v2.add(p1[4]);
    v2.add(p1[5]);

    v3 = v1.minus(v2);
    assert_equal 1, v3.get_size
    assert_equal 1, p1.get(v3[0])
  end

  def test_c16_View_comparisons
    p1 = Metakit::IntProp.new("p1");

    v1 = Metakit::View.new
    v1.add(p1[1]);
    v1.add(p1[2]);
    v1.add(p1[3]);
    v1.add(p1[4]);
    v1.add(p1[5]);

    assert_equal v1, v1
    assert_equal v1, v1.slice(0)
    assert v1.slice(0, 2) < v1.slice(0, 3)
    assert_equal v1.slice(0, 3), v1.slice(0, 3)
    assert v1.slice(0, 4) > v1.slice(0, 3)
    assert v1.slice(0, 3) < v1.slice(1, 3)
    assert v1.slice(0, 3) < v1.slice(1, 4)
    assert v1.slice(1, 3) > v1.slice(0, 3)
    assert v1.slice(1, 4) > v1.slice(0, 3)
  end

  def test_c17_Join_operation
    p1, p2 = Metakit::StringProp[:p1, :p2]
    p3     = Metakit::IntProp.new("p3");

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[""]);
    v1.add(p1["1"] + p2["a"]);
    v1.add(p1["12"] + p2["ab"]);
    v1.add(p1["123"] + p2["abc"]);

    v2.add(p1["1"] + p3[1]);
    v2.add(p1["12"] + p3[1]);
    v2.add(p1["12"] + p3[2]);
    v2.add(p1["123"] + p3[1]);
    v2.add(p1["123"] + p3[2]);
    v2.add(p1["123"] + p3[3]);

    v3 = v1.join(p1, v2); #// inner join
    assert_equal 6, v3.get_size

    assert_equal "1", p1.get(v3[0])
    assert_equal "12", p1.get(v3[1])
    assert_equal "12", p1.get(v3[2])
    assert_equal "123", p1.get(v3[3])
    assert_equal "123", p1.get(v3[4])
    assert_equal "123", p1.get(v3[5])

    assert_equal "a", p2.get(v3[0])
    assert_equal "ab", p2.get(v3[1])
    assert_equal "ab", p2.get(v3[2])
    assert_equal "abc", p2.get(v3[3])
    assert_equal "abc", p2.get(v3[4])
    assert_equal "abc", p2.get(v3[5])

    assert_equal 1, p3.get(v3[0])
    assert_equal 1, p3.get(v3[1])
    assert_equal 2, p3.get(v3[2])
    assert_equal 1, p3.get(v3[3])
    assert_equal 2, p3.get(v3[4])
    assert_equal 3, p3.get(v3[5])

    v3 = v1.join(p1, v2, true); #// outer join
    assert_equal 7, v3.get_size

    assert_equal "", p1.get(v3[0])
    assert_equal "1", p1.get(v3[1])
    assert_equal "12", p1.get(v3[2])
    assert_equal "12", p1.get(v3[3])
    assert_equal "123", p1.get(v3[4])
    assert_equal "123", p1.get(v3[5])
    assert_equal "123", p1.get(v3[6])

    assert_equal "", p2.get(v3[0])
    assert_equal "a", p2.get(v3[1])
    assert_equal "ab", p2.get(v3[2])
    assert_equal "ab", p2.get(v3[3])
    assert_equal "abc", p2.get(v3[4])
    assert_equal "abc", p2.get(v3[5])
    assert_equal "abc", p2.get(v3[6])

    assert_equal 0, p3.get(v3[0])
    assert_equal 1, p3.get(v3[1])
    assert_equal 1, p3.get(v3[2])
    assert_equal 2, p3.get(v3[3])
    assert_equal 1, p3.get(v3[4])
    assert_equal 2, p3.get(v3[5])
    assert_equal 3, p3.get(v3[6])
  end

  def test_c18_Groupby_sort_fix
    p1, p2, = Metakit::StringProp[:Country, :City]
    p3      = Metakit::ViewProp.new("SubList")

    v1 = Metakit::View.new

    v1.add(p1["US"] + p2["Philadelphia"]);
    v1.add(p1["France"] + p2["Bordeaux"]);
    v1.add(p1["US"] + p2["Miami"]);
    v1.add(p1["France"] + p2["Paris"]);
    v1.add(p1["US"] + p2["Boston"]);
    v1.add(p1["France"] + p2["Nice"]);
    v1.add(p1["US"] + p2["NY"]);
    v1.add(p1["US"] + p2["Miami"]);

    v2 = v1.group_by(p1, p3);
    assert_equal 2, v2.get_size
    assert_equal "France", p1.get(v2[0])
    assert_equal "US", p1.get(v2[1])

    v3 = p3.get(v2[0]);
    assert_equal 3, v3.get_size
    assert_equal "Bordeaux", p2.get(v3[0])
    assert_equal "Nice", p2.get(v3[1])
    assert_equal "Paris", p2.get(v3[2])

    v3 = p3.get(v2[1]);
    assert_equal 5, v3.get_size
    assert_equal "Boston", p2.get(v3[0])
    assert_equal "Miami", p2.get(v3[1])
    assert_equal "Miami", p2.get(v3[2])
    assert_equal "NY", p2.get(v3[3])
    assert_equal "Philadelphia", p2.get(v3[4])
  end

  def test_c19_JoinProp_operation
    p1 = Metakit::StringProp.new("p1");
    p2 = Metakit::ViewProp.new("p2");
    p3 = Metakit::IntProp.new("p3");

    v1  = Metakit::View.new
    v2a = Metakit::View.new
    v2b = Metakit::View.new
    v2c = Metakit::View.new

    v2a.add(p3[1]);
    v2a.add(p3[2]);
    v2a.add(p3[3]);
    v1.add(p1["123"] + p2[v2a]);

    v2b.add(p3[1]);
    v2b.add(p3[2]);
    v1.add(p1["12"] + p2[v2b]);

    v2c.add(p3[1]);
    v1.add(p1["1"] + p2[v2c]);

    v1.add(p1[""]);

    v3 = v1.join_prop(p2); #// inner join
    assert_equal 6, v3.get_size

    assert_equal "123", p1.get(v3[0])
    assert_equal "123", p1.get(v3[1])
    assert_equal "123", p1.get(v3[2])
    assert_equal "12", p1.get(v3[3])
    assert_equal "12", p1.get(v3[4])
    assert_equal "1", p1.get(v3[5])

    assert_equal 1, p3.get(v3[0])
    assert_equal 2, p3.get(v3[1])
    assert_equal 3, p3.get(v3[2])
    assert_equal 1, p3.get(v3[3])
    assert_equal 2, p3.get(v3[4])
    assert_equal 1, p3.get(v3[5])

    v3 = v1.join_prop(p2, true); #// outer join
    assert_equal 7, v3.get_size

    assert_equal "123", p1.get(v3[0])
    assert_equal "123", p1.get(v3[1])
    assert_equal "123", p1.get(v3[2])
    assert_equal "12", p1.get(v3[3])
    assert_equal "12", p1.get(v3[4])
    assert_equal "1", p1.get(v3[5])
    assert_equal "", p1.get(v3[6])

    assert_equal 1, p3.get(v3[0])
    assert_equal 2, p3.get(v3[1])
    assert_equal 3, p3.get(v3[2])
    assert_equal 1, p3.get(v3[3])
    assert_equal 2, p3.get(v3[4])
    assert_equal 1, p3.get(v3[5])
    assert_equal 0, p3.get(v3[6])
  end

  def test_c20_Wide_cartesian_product
    # // added 2nd prop's to do a better test - 1999-12-23
    p1, p2, p3, p4 = Metakit::IntProp[:p1, :p2, :p3, :p4]

    v1 = Metakit::View.new
    v1.add(p1[123] + p2[321]);
    v1.add(p1[234] + p2[432]);
    v1.add(p1[345] + p2[543]);

    v2 = Metakit::View.new
    v2.add(p3[111] + p4[11]);
    v2.add(p3[222] + p4[22]);

    v3 = v1.product(v2);
    assert_equal 6, v3.get_size
    assert_equal 123, p1.get(v3[0])
    assert_equal 321, p2.get(v3[0])
    assert_equal 111, p3.get(v3[0])
    assert_equal 11, p4.get(v3[0])
    assert_equal 123, p1.get(v3[1])
    assert_equal 321, p2.get(v3[1])
    assert_equal 222, p3.get(v3[1])
    assert_equal 22, p4.get(v3[1])
    assert_equal 234, p1.get(v3[2])
    assert_equal 432, p2.get(v3[2])
    assert_equal 111, p3.get(v3[2])
    assert_equal 11, p4.get(v3[2])
    assert_equal 234, p1.get(v3[3])
    assert_equal 432, p2.get(v3[3])
    assert_equal 222, p3.get(v3[3])
    assert_equal 22, p4.get(v3[3])
    assert_equal 345, p1.get(v3[4])
    assert_equal 543, p2.get(v3[4])
    assert_equal 111, p3.get(v3[4])
    assert_equal 11, p4.get(v3[4])
    assert_equal 345, p1.get(v3[5])
    assert_equal 543, p2.get(v3[5])
    assert_equal 222, p3.get(v3[5])
    assert_equal 22, p4.get(v3[5])

    v1.add(p1[456]);
    assert_equal 8, v3.get_size
    v2.add(p2[333]);
    assert_equal 12, v3.get_size
  end

  def test_c21_Join_on_compound_key
    p1, p2, p3, p4 = Metakit::IntProp[:p1, :p2, :p3, :p4]

    v1 = Metakit::View.new
    v2 = Metakit::View.new

    v1.add(p1[1] + p2[11] + p3[111]);
    v1.add(p1[2] + p2[22] + p3[222]);
    v1.add(p1[3] + p2[22] + p3[111]);

    v2.add(p2[11] + p3[111] + p4[1111]);
    v2.add(p2[22] + p3[222] + p4[2222]);
    v2.add(p2[22] + p3[222] + p4[3333]);
    v2.add(p2[22] + p3[333] + p4[4444]);

    # // this works here, but it fails in Python, i.e. Mk4py 2.4.0
    v3 = v1.join(Metakit::View[p2, p3], v2);

    assert_equal 3, v3.get_size

    assert_equal 1, p1.get(v3[0])
    assert_equal 2, p1.get(v3[1])
    assert_equal 2, p1.get(v3[2])

    assert_equal 11, p2.get(v3[0])
    assert_equal 22, p2.get(v3[1])
    assert_equal 22, p2.get(v3[2])

    assert_equal 111, p3.get(v3[0])
    assert_equal 222, p3.get(v3[1])
    assert_equal 222, p3.get(v3[2])

    assert_equal 1111, p4.get(v3[0])
    assert_equal 2222, p4.get(v3[1])
    assert_equal 3333, p4.get(v3[2])
  end

  def test_c22_Groupby_with_selection
    Metakit::Storage.create {|s1|
      v1 = s1.get_as("v1[p1:I,p2:I,p3:I]");
      p1, p2, p3 = Metakit::IntProp[:p1, :p2, :p3]
      p4         = Metakit::ViewProp.new("p4");

      v1.add(p1[0] + p2[1] + p3[10]);
      v1.add(p1[1] + p2[1] + p3[20]);
      v1.add(p1[2] + p2[2] + p3[30]);
      v1.add(p1[3] + p2[3] + p3[40]);
      v1.add(p1[4] + p2[3] + p3[50]);

      s1.commit();
      assert_equal 5, v1.get_size

      v2 = v1.group_by(p2, p4);
      assert_equal 3, v2.get_size

      v3 = p4.get(v2[0]);
      assert_equal 2, v3.get_size
      assert_equal 10, p3.get(v3[0])
      assert_equal 20, p3.get(v3[1])

      v4 = p4.get(v2[1]);
      assert_equal 1, v4.get_size
      assert_equal 30, p3.get(v4[0])

      v5 = p4.get(v2[2]);
      assert_equal 2, v5.get_size
      assert_equal 40, p3.get(v5[0])
      assert_equal 50, p3.get(v5[1])

      v6 = v4.sort();
      assert_equal 1, v6.get_size
      assert_equal 2, p1.get(v6[0])
      assert_equal 30, p3.get(v6[0])
    }
  end
end
