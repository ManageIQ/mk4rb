require 'mk4rb_test_helper'

# These tests are adapted from :
#// tstore5.cpp -- Regression test program, storage tests, part 5
#// $Id: tstore5.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Store5_Test < MetakitBaseTest

  def test_s40_LoadFrom_after_commit
    W("s40a");

    p1 = Metakit::IntProp.new "p1"

    # // create datafile by streaming out
    Metakit::Storage.create {|s1|
      s1.set_structure("a[p1:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);
      assert_equal 123, p1.get(v1[0])
      assert_equal 1, v1.get_size

      Metakit::FileStream.open("s40a", "wb") {|fs1|
        s1.save_to(fs1)
      }
    }
    
    # // it should load just fine
    Metakit::Storage.create {|s2|
      ok = Metakit::FileStream.open("s40a", "rb") {|fs1| 
        s2.load_from(fs1)
      }
      assert ok

      v1 = s2.view("a");
      assert_equal 123, p1.get(v1[0])
      assert_equal 1, v1.get_size
    }

    # // open the datafile and commit a change
    Metakit::Storage.open "s40a", 1 do |s3|
      v1 = s3.view("a");
      assert_equal 123, p1.get(v1[0])
      assert_equal 1, v1.get_size

      p1.set v1[0], 456
      s3.commit
      assert_equal 456, p1.get(v1[0])
      assert_equal 1, v1.get_size
    end

    # // it should load fine and show the last changes
    Metakit::Storage.create {|s4|
      Metakit::FileStream.open("s40a", "rb") {|fs1|
        ok = s4.load_from fs1
        assert ok

        v1 = s4.view "a"
        assert_equal 456, p1.get(v1[0])
        assert_equal 1, v1.get_size
      }
    }

    # // it should open just fine in the normal way as well
    Metakit::Storage.open "s40a", 0 do |s5|
      v1 = s5.view "a"
      assert_equal 456, p1.get(v1[0])
      assert_equal 1, v1.get_size
    end
    #   D(s40a);
    R "s40a"
  end

  #   // 2002-03-13: failure on Win32, Modify calls base class GetNthMemoCol
  def test_s41_Partial_modify_blocked
    W("s41a");

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s41a", 1) {|s1|
      v1 = s1.get_as("a[_B[p1:B]]");

      #// custom viewers did not support partial access in 2.4.3
      v2 = v1.blocked();
      s1.commit();

      v2.set_size(1);

      m = p1.ref(v2[0])
      m.modify(Metakit::Bytes.new("abcdefgh", 8), 0);

      s1.commit();
    }

    # D(s41a);
    R("s41a");
  end

  def test_s42_Get_descriptions
    s1 = Metakit::Storage.default_new
    s1.set_structure("a[p1:I],b[p2:S]")

    assert_equal "a[p1:I],b[p2:S]", s1.description
    assert_equal "p2:S", s1.description("b")
    assert_nil   s1.description("c")
  end

  #   // 2002-04-24: VPI subview ints clobbered
  def test_s43_View_reuse_after_sub_byte_ints
    W("s43a");

    p1 = Metakit::IntProp.new "p1"
    Metakit::Storage.open "s43a", 1 do |s1|
      v1 = s1.get_as "a[p1:I]"

      v1.add(p1[0]);
      v1.add(p1[1]);
      s1.commit();

      v1.set_size(1); #// 1 is an even trickier bug than 0
      s1.commit();

      v1.add(p1[12345]);
      s1.commit();

      assert_equal 12345, p1.get(v1[1])
    end
    #   D(s43a);
    R("s43a");
  end

  def test_s44_Bad_memo_free_space
    W('s44a');

    p1 = Metakit::IntProp.new("p1");
    p2 = Metakit::BytesProp.new("p2");
    Metakit::Storage.open("s44a", 1) {|s1|
      v1 = s1.get_as("a[p1:I,p2:B]");

      data = Metakit::Bytes.default_new
      p = data.set_buffer(12345);
      data.size.times {|i|
        p[i] = i
      }

      v1.add(p2[data]);
      s1.commit();

      p1.set(v1[0], 1)
      s1.commit();

      p1.set(v1[0], 0)
      s1.commit();

      temp = p2.get(v1[0]);
      assert_equal temp, data # // this failed in 2.4.5
    }
      #   D(s44a);
      R('s44a');
  end

  def test_s45_Bad_subview_memo_free_space
    W('s45a');

    p1 = Metakit::IntProp.new("p1");
    p2 = Metakit::ViewProp.new("p2");
    p3 = Metakit::BytesProp.new("p3");
    Metakit::Storage.open("s45a", 1) {|s1|
      v1 = s1.get_as("a[p1:I,p2[p3:B]]");

      data = Metakit::Bytes.default_new
      p = data.set_buffer(12345);
      data.size.times {|i|
        p[i] = i
      }

      v1.set_size(1);
      v2 = p2.get(v1[0]);
      v2.add(p3[data]);
      s1.commit();

      p1.set(v1[0], 1)
      s1.commit();
      
      p1.set(v1[0], 0)
      s1.commit();

      v3 = p2.get(v1[0]);
      temp = p3.get(v3[0]);
      assert_equal temp, data # // this failed in 2.4.5
    }

    #   D(s45a);
    R('s45a');
  end

  def test_s46_LoadFrom_after_commit
    W "s46a"

    p1 = Metakit::IntProp.new "p1"

    Metakit::Storage.open "s46a", 1 do |s1|
      s1.set_structure "a[p1:I]"
      v1 = s1.view "a"

      v1.add(p1.as_row(11))
      v1.add(p1.as_row(22))
      v1.add(p1.as_row(33))
      v1.add(p1.as_row(44))
      v1.add(p1.as_row(55))
      v1.add(p1.as_row(66))
      v1.add(p1.as_row(77))
      v1.add(p1.as_row(88))
      v1.add(p1.as_row(99))

      s1.commit
    end

    Metakit::Storage.open "s46a", 1 do |s2|
      v2 = s2.view "a"

      v2.add(p1.as_row(1000)) # // force 1->2 byte ints
      v2.insert_row_at 7, Metakit::Row.new
      v2.insert_row_at 4, Metakit::Row.new

      assert_equal 66, p1.get(v2.get_at(6))
      assert_equal 0,  p1.get(v2.get_at(8))
      assert_equal 88, p1.get(v2.get_at(9))
      assert_equal 77, p1.get(v2.get_at(7))

      s2.commit
    end

#   D(s46a);
    R "s46a"
  end

#   // 2004-01-16 bad property type crashes MK 2.4.9.2 and before
#   // this hits an assertion in debug mode, so then it has to be disabled
  def test_s47_Defining_bad_property_type
    p1 = Metakit::IntProp.new("p2");

    Metakit::Storage.create {|s1|
      v1 = s1.get_as("v1[p1:A]");
# #else 
#     // assertions are enabled, turn this into a dummy test instead
#     c4_View v1 = s1.GetAs("v1[p1:I]");
# #endif 
      v1.add(p1[123]);

     assert_equal 1, v1.get_size
     assert_equal 123, p1.get(v1[0])
    }
  end

#   // 2004-01-18 file damaging bug, when resizing a comitted subview
#   // to empty, committing, and then resizing back to containing data.
#   // Fortunately this usage pattern never happened in blocked views!
  def test_s48_Resize_subview_to_zero_and_back
    W("s48a");
    W("s48b");

    Metakit::Storage.open("s48a", 1) {|s1|
      v1 = s1.get_as("v1[v2[p1:I]]");
      v1.set_size(1);
      s1.commit();
    }
    
    Metakit::Storage.open("s48a", 1) {|s1|
      v1 = s1.view("v1");
      v1.set_size(0);
      s1.commit();
#       // the problem is that the in-memory copy has forgotten that it
#       // has nothing left on disk, and a comparison is done later on to
#       // avoid saving unmodified data - the bad decision is that data has
#       // not changed, but actually it has and must be reallocated!
#       // (fixes are in c4_FormatV::Insert and c4_FormatV::Remove)
      v1.set_size(1);
      s1.commit();
      # // at this point, the 2.4.9.2 file is corrupt!
      Metakit::FileStream.open("s48b", "wb") {|fs1|
        s1.save_to(fs1);
      }
    }
    
    # // using this damaged datafile will then crash
    Metakit::Storage.open("s48a", 0) {|s1|
      v1 = s1.view("v1");
      v1.set_size(2);
    }

#   D(s48a);
#   D(s48b);
    R("s48a");
    R("s48b");
  end

  #   // 2004-01-20 better handling of bad input: ignore repeated props
  def test_s49_Specify_conflicting_properties
    W "s49a"

    Metakit::Storage.open "s49a", 1 do |s1|
      v1 = s1.get_as "v1[p1:I,p1:S]"
      v2 = s1.get_as "v2[p1:I,P1:S]"
      v3 = s1.get_as "v3[v3[^]]"
      
      assert_equal "v1[p1:I],v2[p1:I],v3[v3[^]]", s1.description
      s1.commit
    end

#   D(s49a);
    R "s49a"
  end

  def test_s50_Free_space_usage
    p1 = Metakit::IntProp.new "p1"

    s1 = Metakit::Storage.new "s50a", 1
    v1 = s1.get_as "a[p1:I]"

    v1.add(p1.as_row(12345))

    s1.commit
    c, b = s1.freespace
    assert_equal 0, c
    assert_equal 0, b

    v1.add(p1.as_row(2345))

    s1.commit
    c, b = s1.freespace
    assert_equal 1, c
    assert_equal 18, b

    s1.commit
    c, b = s1.freespace
    assert_equal 1, c
    assert_equal 6, b

    v1.add(p1.as_row(345))

    s1.commit
    c, b = s1.freespace
    assert_equal 2, c
    assert_equal 56, b
    s1.commit
    c, b = s1.freespace
    assert_equal 1, c
    assert_equal 44, b

    s1.close!
    #   D(s50a);
    R("s50a")
  end
end
