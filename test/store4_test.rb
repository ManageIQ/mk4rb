require 'mk4rb_test_helper'

# These tests are adapted from :
#// tstore4.cpp -- Regression test program, storage tests, part 4
#// $Id: tstore4.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Store4_Test < MetakitBaseTest
  def test_s30_Memo_storage
    W('s30a');

    hi = Metakit::Bytes.new("hi", 2);
    gday = Metakit::Bytes.new("gday", 4);
    hello = Metakit::Bytes.new("hello", 5);

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s30a", 1) {|s1|
      s1.set_structure("a[p1:B]");
      v1 = s1.view("a");

      v1.add(p1[hi]);
      assert_equal hi, p1.get(v1[0])

      v1.add(p1[hello]);
      assert_equal hi, p1.get(v1[0])
      assert_equal hello, p1.get(v1[1])

      v1.insert_row_at(1, p1[gday]);
      assert_equal hi, p1.get(v1[0])
      assert_equal gday, p1.get(v1[1])
      assert_equal hello, p1.get(v1[2])

      s1.commit();
      assert_equal hi, p1.get(v1[0])
      assert_equal gday, p1.get(v1[1])
      assert_equal hello, p1.get(v1[2])
    }

    #D(s30a);
    R('s30a');
  end

  #// this failed in the unbuffered 1.8.5a interim release in Mk4tcl 1.0.5
  def test_s31_Check_sort_buffer_use
    W('s31a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("s31a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      v1.add(p1[3]);
      v1.add(p1[1]);
      v1.add(p1[2]);
      s1.commit();

      v2 = v1.sort_on(p1);
      assert_equal 3, v2.get_size
      assert_equal 1, p1.get(v2[0])
      assert_equal 2, p1.get(v2[1])
      assert_equal 3, p1.get(v2[2])
    }

    #D(s31a);
    R('s31a');
  end

  # this failed in 1.8.6, fixed 19990828
  def test_s32_Set_memo_empty_or_same_size
    W('s32a');

    empty = Metakit::Bytes.default_new;
    full = Metakit::Bytes.new("full", 4);
    more = Metakit::Bytes.new("more", 4);

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s32a", 1) {|s1|
      s1.set_structure("a[p1:B]");
      v1 = s1.view("a");

      v1.add(p1[full]);
      assert_equal full, p1.get(v1[0])
      s1.commit();
      assert_equal full, p1.get(v1[0])

      p1.set(v1[0], empty)
      assert_equal empty, p1.get(v1[0])
      s1.commit();
      assert_equal empty, p1.get(v1[0])

      p1.set(v1[0], more)
      assert_equal more, p1.get(v1[0])
      s1.commit();
      assert_equal more, p1.get(v1[0])

      p1.set(v1[0], full)
      assert_equal full, p1.get(v1[0])
      s1.commit();
      assert_equal full, p1.get(v1[0])
    }
    #D(s32a);
    R('s32a');
  end

   # // this failed in 1.8.6, fixed 19990828
   def test_s33_Serialize_memo_fields
     W('s33a');
     W('s33b');
     W('s33c');

     hi = Metakit::Bytes.new("hi", 2);
     gday = Metakit::Bytes.new("gday", 4);
     hello = Metakit::Bytes.new("hello", 5);

     p1 = Metakit::BytesProp.new("p1");

     Metakit::Storage.open("s33a", 1) {|s1|
       s1.set_structure("a[p1:B]");
       v1 = s1.view("a");

       v1.add(p1[hi]);
       v1.add(p1[gday]);
       v1.add(p1[hello]);
       assert_equal hi, p1.get(v1[0])
       assert_equal gday, p1.get(v1[1])
       assert_equal hello, p1.get(v1[2])
       s1.commit();
       assert_equal hi, p1.get(v1[0])
       assert_equal gday, p1.get(v1[1])
       assert_equal hello, p1.get(v1[2])

       Metakit::FileStream.open("s33b", "wb") {|fs1|
         s1.save_to(fs1);
       }

       Metakit::Storage.open("s33c", 1) {|s2|
         Metakit::FileStream.open("s33b", "rb") {|fs2|
           s2.load_from(fs2);
         }

         v2 = s2.view("a");
         assert_equal hi, p1.get(v2[0])
         assert_equal gday, p1.get(v2[1])
         assert_equal hello, p1.get(v2[2])
         s2.commit();
         assert_equal hi, p1.get(v2[0])
         assert_equal gday, p1.get(v2[1])
         assert_equal hello, p1.get(v2[2])
         s2.commit();
         assert_equal hi, p1.get(v2[0])
         assert_equal gday, p1.get(v2[1])
         assert_equal hello, p1.get(v2[2])
       }
     }
     #   D(s33a);
     #   D(s33b);
     #   D(s33c);
     R('s33a');
     R('s33b');
     R('s33c');
   end

   #// check smarter commit and commit failure on r/o
   def test_s34_Smart_and_failed_commits
     W('s34a');

     p1 = Metakit::IntProp.new("p1");

     Metakit::Storage.open("s34a", 1) {|s1|
       s1.set_structure("a[p1:I]");
       v1 = s1.view("a");
       v1.add(p1[111]);
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])
       f1 = s1.commit();
       assert(f1);
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])

       f2 = s1.commit();
       assert(f2); #// succeeds, but should not write anything
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])
     }
     
     Metakit::Storage.open("s34a", 0) {|s1|
       v1 = s1.view("a");
       v1.add(p1[222]);
       assert_equal 2, v1.get_size
       assert_equal 111, p1.get(v1[0])
       assert_equal 222, p1.get(v1[1])
       f1 = s1.commit();
       assert(!f1)
       assert_equal 2, v1.get_size
       assert_equal 111, p1.get(v1[0])
       assert_equal 222, p1.get(v1[1])
     }

     #   D(s34a);
     R('s34a');
   end

   def test_s35_Datafile_with_preamble
     W('s35a');

     Metakit::FileStream.open("s35a", "wb") {|fs1|
       fs1.write("abc")
     }

     p1 = Metakit::IntProp.new("p1");
     Metakit::Storage.open("s35a", 1) {|s1|
       s1.set_structure("a[p1:I]");
       v1 = s1.view("a");
       v1.add(p1[111]);
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])

       f1 = s1.commit();
       assert(f1);
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])
       f2 = s1.commit();
       assert (f2); #// succeeds, but should not write anything
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])
    }

     buffer = File.open("s35a", "rb") {|f|
       f.read 3
     }
     n1 = buffer.length
     assert_equal n1, 3
     assert_equal buffer, "abc"


     Metakit::Storage.open("s35a", 0) {|s1|
       v1 = s1.view("a");
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])
       v1.add(p1[222]);
       assert_equal 2, v1.get_size
       assert_equal 111, p1.get(v1[0])
       assert_equal 222, p1.get(v1[1])
       f1 = s1.commit();
       assert(!f1);
       assert_equal 2, v1.get_size
       assert_equal 111, p1.get(v1[0])
       assert_equal 222, p1.get(v1[1])
    }

     #   D(s35a);
     R('s35a');
   end

   def test_s36_Commit_after_load
     W('s36a');
     W('s36b');

     p1 = Metakit::IntProp.new("p1");

     Metakit::Storage.open("s36a", 1) {|s1|
       s1.set_structure("a[p1:I]");
       v1 = s1.view("a");
       v1.add(p1[111]);
       assert_equal 1, v1.get_size
       assert_equal 111, p1.get(v1[0])

       Metakit::FileStream.open("s36b", "wb") {|fs1|
         s1.save_to(fs1);
       }

       p1.set(v1[0], 222);
       v1.add(p1[333]);
       f1 = s1.commit();
       assert(f1);
       assert_equal 2, v1.get_size
       assert_equal 222, p1.get(v1[0])
       assert_equal 333, p1.get(v1[1])

       Metakit::FileStream.open("s36b", "rb") {|fs2|
         s1.load_from(fs2);
         # //A(v1.GetSize() == 0); // should be detached, but it's still 2

         v2 = s1.view("a");
         assert_equal 1, v2.get_size
         assert_equal 111, p1.get(v2[0])

         #// this fails in 2.4.0, reported by James Lupo, August 2001
         f2 = s1.commit();
         assert(f2);
       }
     }

     #   D(s36a);
     #   D(s36b);
     R('s36a');
     R('s36b');
   end

  #// fails in 2.4.1, reported Oct 31. 2001 by Steve Baxter
  def test_s37_Change_short_partial_fields
    W('s37a');

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s37a", 1) {|s1|
      v1 = s1.get_as("v1[key:I,p1:B]");

      v1.add(p1[Metakit::Bytes.new("12345", 6)]);
      assert_equal 1, v1.get_size
      s1.commit();

      buf = p1.get(v1[0]);
      assert_equal 6, buf.size
      assert_equal buf, Metakit::Bytes.new("12345", 6)
      
      buf = p1.ref(v1[0]).access(1, 3);
      assert_equal buf, Metakit::Bytes.new("234", 3)

      p1.ref(v1[0]).modify(Metakit::Bytes.new("ab", 2), 2, 0);
      s1.commit();

      buf = p1.get(v1[0]);
      assert_equal buf, Metakit::Bytes.new("12ab5", 6)
    }
    #   D(s37a);
    R('s37a');
  end

  #// Gross memory use (but no leaks), January 2002, Murat Berk
  def test_s38_Lots_of_empty_subviews
    W('s38a');

    p1 = Metakit::BytesProp.new("p1");

    Metakit::Storage.open("s38a", 1) {|s1|
      v = s1.get_as("v[v1[p1:S]]");

      v.set_size(100000);
      s1.commit();
    }
    
    Metakit::Storage.open("s38a", 1) {|s2|
      v2 = s2.view("v");
      # // this should not materialize all the empty subviews
      v2.set_size(v2.get_size() + 1);
      # // nor should this
      s2.commit();
    }
    
    Metakit::Storage.open("s38a", 1) {|s3|
      v3 = s3.view("v");
      v3.remove_at(1, v3.get_size() - 2);
      assert_equal 2, v3.get_size
      s3.commit();
    }

    #   D(s38a);
    R('s38a');
  end

  #   // Fix bug introduced on 7-2-2002, as reported by M. Berk
  def test_s39_Do_not_detach_empty_top_level_views
    W('s39a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("s39a", 1) {|s1|
      v1 = s1.get_as("v1[p1:I]");
      s1.commit();
      assert_equal 0, v1.get_size
      v1.add(p1[123]);
      assert_equal 1, v1.get_size
      s1.commit();
      v2 = s1.view("v1");
      assert_equal 1, v2.get_size() #// fails with 0 due to recent bug
    }
    #   D(s39a);
    R('s39a');
  end
end
