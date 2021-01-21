require 'mk4rb_test_helper'

# These tests are adapted from :
#// tnotify.cpp -- Regression test program, notification tests
#// $Id: tnotify.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Notify_Test < MetakitBaseTest

  def test_n01_Add_to_selection
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new 
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size

    v2 = v1.select_range(p1[200], p1[333])
    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])

    v1.add(p1[300]);
    assert_equal 7, v1.get_size
    assert_equal 4, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])
    assert_equal 300, p1.get(v2[3])

    v1.add(p1[199]);
    assert_equal 8, v1.get_size
    assert_equal 4, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])
    assert_equal 300, p1.get(v2[3])
  end

  def test_n02_Remove_from_selection
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size
    
    v2 = v1.select_range(p1[200], p1[333]);

    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])

    v1.remove_at(2);

    assert_equal 5, v1.get_size
    assert_equal 2, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 234, p1.get(v2[1])

    v1.remove_at(2);
    assert_equal 4, v1.get_size
    assert_equal 2, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 234, p1.get(v2[1])
  end

  def test_n03_Modify_into_selection
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size

    v2 = v1.select_range(p1[200], p1[333]);
    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])

    p1.set v1[5], 300
    assert_equal 4, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])
    assert_equal 300, p1.get(v2[3])
  end

  def test_n04_Modify_out_of_selection
    p1 = Metakit::IntProp.new "p1"
    v1 = Metakit::View.new
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);

    assert_equal 6, v1.get_size
    v2 = v1.select_range(p1[200], p1[333]);
    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])

    p1.set v1[2], 100;
    assert_equal 2, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 234, p1.get(v2[1])
  end

  def test_n05_Add_to_sorted
    p1 = Metakit::IntProp.new("p1");
    v1 = Metakit::View.new
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size
    v2 = v1.sort

    assert_equal 6, v2.get_size
    assert_equal 111, p1.get(v2[0])
    assert_equal 123, p1.get(v2[1])
    assert_equal 222, p1.get(v2[2])
    assert_equal 234, p1.get(v2[3])
    assert_equal 333, p1.get(v2[4])
    assert_equal 345, p1.get(v2[5])

    v1.add(p1[300]);
    assert_equal 7, v2.get_size
    assert_equal 111, p1.get(v2[0])
    assert_equal 123, p1.get(v2[1])
    assert_equal 222, p1.get(v2[2])
    assert_equal 234, p1.get(v2[3])
    assert_equal 300, p1.get(v2[4])
    assert_equal 333, p1.get(v2[5])
    assert_equal 345, p1.get(v2[6])
  end

  def test_n06__Remove_from_sorted
    p1 = Metakit::IntProp.new("p1");
    v1 = Metakit::View.new
    v1.add(p1[111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size
    v2 = v1.sort();
    assert_equal 6, v2.get_size()
    assert_equal 111, p1.get(v2[0])
    assert_equal 123, p1.get(v2[1])
    assert_equal 222, p1.get(v2[2])
    assert_equal 234, p1.get(v2[3])
    assert_equal 333, p1.get(v2[4])
    assert_equal 345, p1.get(v2[5])
    v1.remove_at(2);
    assert_equal 5, v2.get_size
    assert_equal 111, p1.get(v2[0])
    assert_equal 123, p1.get(v2[1])
    assert_equal 222, p1.get(v2[2])
    assert_equal 234, p1.get(v2[3])
    assert_equal 345, p1.get(v2[4])
  end

  def test_n07__New_property_through_sort
    p1, p2 = Metakit::IntProp[:p1, :p2]
    v1 = Metakit::View.new
    v1.add(p1[11]);
    v1.add(p1[1]);
    v1.add(p1[111]);
    assert v1.find_property(p2.get_id) < 0

    v2 = v1.sort_on(p1);
    assert v2.find_property(p2.get_id) < 0

    assert_equal 3, v2.get_size
    assert_equal 1, p1.get(v2[0])
    assert_equal 11, p1.get(v2[1])
    assert_equal 111, p1.get(v2[2])

    p2.set v1[0], 22
    assert_equal 1, v1.find_property(p2.get_id)
    assert_equal 1, v2.find_property(p2.get_id)

    assert_equal 22, p2.get(v2[1])
  end

  def test_n08__Nested_project_and_select
    p1, p2 = Metakit::IntProp[:p1, :p2]
    v1 = Metakit::View.new
    v1.add(p1[10] + p2[1]);
    v1.add(p1[11]);
    v1.add(p1[12] + p2[1]);
    v1.add(p1[13]);
    v1.add(p1[14] + p2[1]);
    v1.add(p1[15]);
    v1.add(p1[16] + p2[1]);
    assert_equal 7, v1.get_size

    v2 = v1.select(p2[1]);
    assert_equal 4, v2.get_size
    assert_equal 10, p1.get(v2[0])
    assert_equal 12, p1.get(v2[1])
    assert_equal 14, p1.get(v2[2])
    assert_equal 16, p1.get(v2[3])

    v3 = v2.project(p1);
    assert_equal 4, v3.get_size
    assert_equal 10, p1.get(v3[0])
    assert_equal 12, p1.get(v3[1])
    assert_equal 14, p1.get(v3[2])
    assert_equal 16, p1.get(v3[3])

    assert_equal 0, p2.get(v3[0])
    assert_equal 0, p2.get(v3[1])
    assert_equal 0, p2.get(v3[2])
    assert_equal 0, p2.get(v3[3])
  end

  def test_n09__Multiple_dependencies
    p1, p2 = Metakit::IntProp[:p1, :p2]
    v1 = Metakit::View.new
    v1.add(p1[111] + p2[1111]);
    v1.add(p1[222]);
    v1.add(p1[333]);
    v1.add(p1[345]);
    v1.add(p1[234]);
    v1.add(p1[123]);
    assert_equal 6, v1.get_size

    v2 = v1.select_range(p1[200], p1[333]);
    assert_equal 3, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 333, p1.get(v2[1])
    assert_equal 234, p1.get(v2[2])

    v3 = v1.select_range(p1[340], p1[350]);
    assert_equal 1, v3.get_size
    assert_equal 345, p1.get(v3[0])

    v4 = v2.sort_on(p1);
    assert_equal 3, v4.get_size
    assert_equal 222, p1.get(v4[0])
    assert_equal 234, p1.get(v4[1])
    assert_equal 333, p1.get(v4[2])

    v5 = v3.sort_on(p1);
    assert_equal 1, v5.get_size
    assert_equal 345, p1.get(v5[0])

    p1.set v1[2], 346

    assert_equal 2, v2.get_size
    assert_equal 222, p1.get(v2[0])
    assert_equal 234, p1.get(v2[1])

    assert_equal 2, v3.get_size
    assert_equal 346, p1.get(v3[0])
    assert_equal 345, p1.get(v3[1])

    assert_equal 2, v4.get_size
    assert_equal 222, p1.get(v4[0])
    assert_equal 234, p1.get(v4[1])

    assert_equal 2, v5.get_size
    assert_equal 345, p1.get(v5[0])
    assert_equal 346, p1.get(v5[1])
  end

  def test_n10_Modify_sorted_duplicates
    p1 = Metakit::IntProp.new("p1");
    v1 = Metakit::View.new
    v1.set_size(3);
    p1.set v1[0], 0

    v2 = v1.sort
    p1.set v1[0], 1
    p1.set v1[1], 1 # // crashed in 1.5, fix in: c4_SortSeq::PosInMap
  end

  def test_n11_Resize_compound_derived_view
    p1, p2 = Metakit::IntProp[:p1, :p2]
    v1 = Metakit::View[p1, p2]
    v2 = v1.select_range(p2[200], p2[333]);
    v3 = v2.sort_on(p1);
    assert_equal 0, v2.get_size
    assert_equal 0, v3.get_size
    v1.set_size(1) # // crashed in 1.5, fix in: c4_FilterSeq::Match
    assert_equal 1, v1.get_size()
    assert_equal 0, v2.get_size()
    assert_equal 0, v3.get_size()
    v1[0].assign p2[300];
    assert_equal 1, v1.get_size()
    assert_equal 1, v2.get_size()
    assert_equal 1, v3.get_size()
    assert_equal 300, p2.get(v2[0])
    v1.add(p1[199]);
    assert_equal 2, v1.get_size()
    assert_equal 1, v2.get_size()
    assert_equal 300, p2.get(v2[0])
  end

  def test_n12_Alter_multiply_derived_view
    p1 = Metakit::IntProp.new("p1");
    p2, p3 = Metakit::StringProp[:p2, :p3]
    v1 = Metakit::View[p1, p2]
    v2 = v1.select(p1[1]);
    v3 = v2.sort_on(p2);
    v4 = v1.select(p1[2]);
    v5 = v4.sort_on(p2);

    v1.add(p1[1] + p2["een"] + p3["1"]);
    v1.add(p1[1] + p2["elf"] + p3["11"]);
    v1.add(p1[2] + p2["twee"] + p3["2"]);
    v1.add(p1[2] + p2["twaalf"] + p3["12"]);
    v1.add(p1[2] + p2["twintig"] + p3["20"]);
    v1.add(p1[2] + p2["tachtig"] + p3["80"]);

    assert_equal 6, v1.get_size()
    assert_equal 2, v2.get_size()
    assert_equal 2, v3.get_size()
    assert_equal 4, v4.get_size()
    assert_equal 4, v5.get_size()

    assert_equal "2",  p3.get(v1[2])
    assert_equal "2",  p3.get(v4[0])
    
    assert_equal "1",  p3.get(v3[0])
    assert_equal "11", p3.get(v3[1])
    
    assert_equal "80", p3.get(v5[0])
    assert_equal "12", p3.get(v5[1])
    assert_equal "2",  p3.get(v5[2])
    assert_equal "20", p3.get(v5[3])

    v1[3].assign(p1[2] + p2["twaalf"] + p3["12+"])

    assert_equal "1", p3.get(v3[0])
    assert_equal "11", p3.get(v3[1])

    assert_equal "12+", p3.get(v1[3])
    assert_equal "12+", p3.get(v4[1])

    assert_equal "80", p3.get(v5[0])
    assert_equal "12+", p3.get(v5[1])
    assert_equal "2", p3.get(v5[2])
    assert_equal "20", p3.get(v5[3])
  end

  def test_n13_Project_without
    p1, p2 = Metakit::IntProp[:p1, :p2]
    v1 = Metakit::View.new

    v1.add(p1[1] + p2[2]);
    n1 = v1.num_properties
    assert_equal 2, n1

    v2 = v1.project_without(p2);
    n2 = v2.num_properties
    assert_equal 1, n2
  end

  #   // this failed in 2.4.8, reported by S. Selznick, 2002-11-22
  def test_n14_Insert_in_non_mapped_position
    W "n14a"

    p1 = Metakit::IntProp.new "p1"
    Metakit::Storage.open "n14a", 1 do |s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");

      [0, 1, 2, 0, 1, 2, 0, 1, 2, 0].each {|c|
        v1.add(p1[c])
      }

      assert_equal 10, v1.get_size
      v2 = v1.select(p1[1]);
      assert_equal 3, v2.get_size

      v1.insert_row_at(3, p1[6]);
      assert_equal 11, v1.get_size
      assert_equal 3, v2.get_size

      v1.insert_row_at(7, p1[1]);
      assert_equal 12, v1.get_size
      assert_equal 4, v2.get_size

      s1.commit
    end
    #   D(n14a);
    R "n14a"
  end
end
