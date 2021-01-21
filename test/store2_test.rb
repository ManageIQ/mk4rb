require 'mk4rb_test_helper'

# These tests are adapted from :
#// tstore2.cpp -- Regression test program, storage tests, part 2
#// $Id: tstore2.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Store2_Test < MetakitBaseTest

  def test_s10_Stream_storage
    W('s10a');
    W('s10b');
    W('s10c');

    #// s10a is original
    #// s10b is a copy, random access
    #// s10c is a serialized copy
    p1 = Metakit::StringProp.new("p1");
    p2 = Metakit::ViewProp.new("p2");
    p3 = Metakit::IntProp.new("p3");

    Metakit::Storage.open("s10a", 1) {|s1|
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
    
    Metakit::Storage.open("s10a", 0) {|s1|
      Metakit::Storage.open("s10b", 1) {|s2|
        s2.set_structure("a[p1:S,p2[p3:I]]");
        s2.view_and_assign("a", s1.view("a"))
        s2.commit();
      }
    }

    Metakit::Storage.open("s10b", 0) {|s3|
      Metakit::FileStream.open("s10c", "wb") {|fs1|
        s3.save_to(fs1);
      }
    }

    Metakit::Storage.open("s10c", 0) {|s1|
      #// new after 2.01: serialized is no longer special

      v1 = s1.view("a");
      assert_equal 3, v1.get_size
      v2 = p2.get(v1[0]);
      assert_equal 1, v2.get_size
      v3 = p2.get(v1[1]);
      assert_equal 3, v3.get_size
      v4 = p2.get(v1[2]);
      assert_equal 2, v4.get_size
    }

    Metakit::Storage.create {|s1|
      Metakit::FileStream.open("s10c", "rb") {|fs1|
        s1.load_from(fs1);

        v1 = s1.view("a");
        assert_equal 3, v1.get_size
        v2 = p2.get(v1[0]);
        assert_equal 1, v2.get_size
        v3 = p2.get(v1[1]);
        assert_equal 3, v3.get_size
        v4 = p2.get(v1[2]);
        assert_equal 2, v4.get_size
      }
    }

    Metakit::Storage.open("s10c", 1) {|s1|
      v1 = s1.view("a");
      assert_equal 3, v1.get_size
      v2 = p2.get(v1[0]);
      assert_equal 1, v2.get_size
      v3 = p2.get(v1[1]);
      assert_equal 3, v3.get_size
      v4 = p2.get(v1[2]);
      assert_equal 2, v4.get_size
      v1.add(p1["four"]);
      s1.commit();
    }

    Metakit::Storage.open("s10c", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 4, v1.get_size
      v2 = p2.get(v1[0]);
      assert_equal 1, v2.get_size
      v3 = p2.get(v1[1]);
      assert_equal 3, v3.get_size
      v4 = p2.get(v1[2]);
      assert_equal 2, v4.get_size
      v5 = p2.get(v1[3]);
      assert_equal 0, v5.get_size
    }

    #  D(s10a);
    #D(s10b);
    #D(s10c);
    R('s10a');
    R('s10b');
    R('s10c');
  end

  def test_s11_Commit_and_rollback
    W('s11a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("s11a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();
    }
    
    Metakit::Storage.open("s11a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])
      v1.insert_row_at(0, p1[234]);
      assert_equal 2, v1.get_size
      assert_equal 234, p1.get(v1[0])
      assert_equal 123, p1.get(v1[1])
      s1.rollback();
      # // 19990916 - semantics changed, still 2 rows, but 0 props
      assert_equal 2, v1.get_size
      assert_equal 0, v1.num_properties
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])
    }

    #   D(s11a);
    R('s11a');
  end

  def test_s12_Remove_subview
    W('s12a');

    p1, p3 = Metakit::IntProp[:p1, :p3]
    p2     = Metakit::ViewProp.new("p2");

    Metakit::Storage.open("s12a", 1) {|s1|
      s1.set_structure("a[p1:I,p2[p3:I]]");
      v1 = s1.view("a");
      v2 = Metakit::View.new
      v2.add(p3[234]);
      v1.add(p1[123] + p2[v2]);
      s1.commit();
    }
    
    Metakit::Storage.open("s12a", 1) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])
      v2 = p2.get(v1[0]);
      assert_equal 1, v2.get_size
      assert_equal 234, p3.get(v2[0])
      v1.remove_at(0);
      assert_equal 0, v1.get_size
      s1.commit();
      assert_equal 0, v1.get_size
    }

    # D(s12a);
    R('s12a');
  end

   def test_s13_Remove_middle_subview
     W('s13a');

     p1, p3 = Metakit::IntProp[:p1, :p3]
     p2     = Metakit::ViewProp.new("p2");

     Metakit::Storage.open("s13a", 1) {|s1|
       s1.set_structure("a[p1:I,p2[p3:I]]");
       v1 = s1.view("a");

       v2a = Metakit::View.new
       v2a.add(p3[234]);
       v1.add(p1[123] + p2[v2a]);

       v2b = Metakit::View.new
       v2b.add(p3[345]);
       v2b.add(p3[346]);
       v1.add(p1[124] + p2[v2b]);

       v2c = Metakit::View.new
       v2c.add(p3[456]);
       v2c.add(p3[457]);
       v2c.add(p3[458]);
       v1.add(p1[125] + p2[v2c]);

       s1.commit();
     }
     
     Metakit::Storage.open("s13a", 1) {|s1|
       v1 = s1.view("a");
       assert_equal 3, v1.get_size
       assert_equal 123, p1.get(v1[0])
       assert_equal 124, p1.get(v1[1])
       assert_equal 125, p1.get(v1[2])
       v2a = p2.get(v1[0]);
       assert_equal 1, v2a.get_size
       assert_equal 234, p3.get(v2a[0])
       v2b = p2.get(v1[1]);
       assert_equal 2, v2b.get_size
       assert_equal 345, p3.get(v2b[0])
       v2c = p2.get(v1[2]);
       assert_equal 3, v2c.get_size()
       assert_equal 456, p3.get(v2c[0])
       v1.remove_at(1);
       assert_equal 2, v1.get_size()
       v2a = p2.get(v1[0]);
       assert_equal 1, v2a.get_size()
       assert_equal 234, p3.get(v2a[0])
       v2b = p2.get(v1[1]);
       assert_equal 3, v2b.get_size()
       assert_equal 456, p3.get(v2b[0])
       s1.commit();
       assert_equal 2, v1.get_size()
       assert_equal 123, p1.get(v1[0])
       assert_equal 125, p1.get(v1[1])
     }

     #   D(s13a);
     R('s13a');
   end

   def test_s14_Replace_attached_subview
     W('s14a');

     p1 = Metakit::IntProp.new("p1");
     p2 = Metakit::ViewProp.new("p2");

     Metakit::Storage.open("s14a", 1) {|s1|
       s1.set_structure("a[p1:I,p2[p3:I]]");
       v1 = s1.view("a");
       
       v1.add(p1[123] + p2[Metakit::View.new]);
       assert_equal 1, v1.get_size()

       v1[0] = p2[Metakit::View.new];
       assert_equal 1, v1.get_size()
       assert_equal 0, p1.get(v1[0])

       s1.commit();
     }
     #   D(s14a);
     R('s14a');
   end

   def test_s15_Add_after_removed_subviews
     W('s15a');

     p1, p3 = Metakit::IntProp[:p1, :p3]
     p2     = Metakit::ViewProp.new("p2");

     Metakit::Storage.open("s15a", 1) {|s1|
       s1.set_structure("a[p1:I,p2[p3:I]]");
       v1 = s1.view("a");

       v2 = Metakit::View.new
       v2.add(p3[234]);

       v1.add(p1[123] + p2[v2]);
       v1.add(p1[456] + p2[v2]);
       v1.add(p1[789] + p2[v2]);
       assert_equal 3, v1.get_size()

       v1[0] = v1[2];
       v1.remove_at(2);

       v1[0] = v1[1];
       v1.remove_at(1);

       v1.remove_at(0);

       v1.add(p1[111] + p2[v2]);

       s1.commit();
     }

     #   D(s15a);
     R('s15a');
   end

   def test_s16_Add_after_removed_ints
     W('s16a');

     p1 = Metakit::IntProp.new("p1");

     Metakit::Storage.open("s16a", 1) {|s1|
       s1.set_structure("a[p1:I,p2[p3:I]]");
       v1 = s1.view("a");

       v1.add(p1[1]);
       v1.add(p1[2]);
       v1.add(p1[3]);

       v1.remove_at(2);
       v1.remove_at(1);
       v1.remove_at(0);

       v1.add(p1[4]);

       s1.commit();
     }
     #   D(s16a);
     R('s16a');
   end

   def test_s17_Add_after_removed_strings
     W('s17a');

     p1 = Metakit::StringProp.new("p1");

     Metakit::Storage.open("s17a", 1) {|s1|
       s1.set_structure("a[p1:S,p2[p3:I]]");
       v1 = s1.view("a");

       v1.add(p1["one"]);
       v1.add(p1["two"]);
       v1.add(p1["three"]);

       v1.remove_at(2);
       v1.remove_at(1);
       v1.remove_at(0);

       v1.add(p1["four"]);

       s1.commit();
     }
     #   D(s17a);
     R('s17a');
   end

   def test_s18_Empty_storage
     W('s18a');

     Metakit::Storage.open("s18a", 1) {|s1|
     }
     #   D(s18a);
     R('s18a');
   end

   def test_s19_Empty_view_outlives_storage
     W('s19a');

     v1 = Metakit::View.new
     Metakit::Storage.open("s19a", 1) {|s1|
       v1.assign s1.get_as("a[p1:I,p2:S]")
     }

     #   D(s19a);
     R('s19a');
   end
end
