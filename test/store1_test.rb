require 'mk4rb_test_helper'

# These tests are adapted from :
#// tstore1.cpp -- Regression test program, storage tests, part 1
#// $Id: tstore1.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Store1_Test < MetakitBaseTest

  def test_s00_Simple_storage
    W('s00a');

    Metakit::Storage.open("s00a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      s1.commit();
    }
    # D(s00a);
    R('s00a');
  end

  def test_s01_Integer_storage
    W('s01a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("s01a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      v1.add(p1[456]);
      v1.insert_row_at(1, p1[789]);
      assert_equal 3, v1.get_size
      s1.commit();
      assert_equal 3, v1.get_size
    }

    #D(s01a);
    R('s01a');
  end

  def test_s02_Float_storage
    W('s02a')

    p1 = Metakit::FloatProp.new("p1");
    Metakit::Storage.open("s02a", 1) {|s1|
      s1.set_structure("a[p1:F]");
      v1 = s1.view("a");
      v1.add(p1[12.3]);
      v1.add(p1[45.6]);
      v1.insert_row_at(1, p1[78.9]);
      s1.commit();
    }
    #D(s02a);
    R('s02a');
  end

  def test_s03_String_storage
    W('s03a');

    p1 = Metakit::StringProp.new("p1");
    Metakit::Storage.open("s03a", 1) {|s1|
      s1.set_structure("a[p1:S]");
      v1 = s1.view("a");
      v1.add(p1["one"]);
      v1.add(p1["two"]);
      v1.insert_row_at(1, p1["three"]);
      s1.commit();
    }
    # D(s03a);
    R('s03a');
  end

  def test_s04_View_d storage
    W('s04a');

    p1 = Metakit::StringProp.new("p1");
    p2 = Metakit::ViewProp.new("p2");
    p3 = Metakit::IntProp.new("p3");
    Metakit::Storage.open("s04a", 1) {|s1|
      s1.set_structure("a[p1:S,p2[p3:I]]");
      v1 = s1.view("a");
      v1.add(p1["one"]);
      v1.add(p1["two"]);
      v2 = p2.get(v1[0]);
      v2.add(p3[1]);
      v2 = p2.get(v1[1]);
      v2.add(p3[11]);
      v2.add(p3[22]);
      v1.insert_row_at(1, p1["three"]);
      v2 = p2.get(v1[1]);
      v2.add(p3[111]);
      v2.add(p3[222]);
      v2.add(p3[333]);
      s1.commit();
    }

    #D(s04a);
    R('s04a');
  end

  def test_s05_Store_and_reload
    W('s05a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("s05a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
    }

    Metakit::Storage.open("s05a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])
    }

    #D(s05a);
    R('s05a');
  end

  def test_s06_Commit_twice
    W('s06a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("s06a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
      v1.add(p1[234]);
      s1.commit();
    }

    Metakit::Storage.open("s06a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 2, v1.get_size
      assert_equal 123, p1.get(v1[0])
      assert_equal 234, p1.get(v1[1])
    }

    # D(s06a);
    R('s06a');
  end

  def test_s07_Commit_modified
    W('s07a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("s07a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
      p1.set(v1[0], 234)
      s1.commit();
    }

    Metakit::Storage.open("s07a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 234, p1.get(v1[0])
    }

    #D(s07a);
    R('s07a');
  end

  def test_s08_View_after_storage
    W('s08a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("s08a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
    }
    
    v1 = Metakit::View.new
    Metakit::Storage.open("s08a", 0) {|s1|
      v1 = s1.view("a");
    }
    # // 19990916 - semantics changed, view now 1 row, but 0 props
    assert_equal 1, v1.get_size
    assert_equal 0, v1.num_properties
    v1.insert_row_at(0, p1[234]);
    assert_equal 2, v1.get_size
    assert_equal 234, p1.get(v1[0])
    assert_equal 0, p1.get(v1[1]) # // the original value is gone

    #D(s08a);
    R('s08a');
  end

  def test_s09_Copy_storage
    W('s09a');
    W('s09b');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("s09a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
    }

    Metakit::Storage.open("s09a", 0) {|s1|
      Metakit::Storage.open("s09b", 1) {|s2|
        s2.set_structure("a[p1:I]");
        s2.view_and_assign("a", s1.view("a"))
        s2.commit();
      }
    }

    #D(s09a);
    #D(s09b);
    R('s09a');
    R('s09b');
  end
end
