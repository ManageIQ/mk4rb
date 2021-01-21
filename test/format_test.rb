require 'mk4rb_test_helper'

# These tests are adapted from: 
# // tformat.cpp -- Regression test program, (re-)format tests
# // $Id: tformat.cpp 1230 2007-03-09 15:58:53Z jcw $
# // This is part of Metakit, the homepage is http://www.equi4.com/metakit.html
 
class FormatTest < MetakitBaseTest

  def test_f01_Add_view_to_format
    W('f01a');

    p1, p2 = Metakit::IntProp[:p1, :p2]

    Metakit::Storage.open("f01a", 1) {|s1|
      s1.set_structure("a[p1:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);
      s1.commit();

      v2 = s1.get_as("b[p2:I]");

      v2.add(p2[345]);
      v2.add(p2[567]);

      s1.commit();
    }

    Metakit::Storage.open("f01a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])

      v2 = s1.view("b");
      assert_equal 2, v2.get_size
      assert_equal 345, p2.get(v2[0])
      assert_equal 567, p2.get(v2[1])
    }

    # D(f01a);
    R('f01a');
  end

  def test_f02_Remove_view_from_format
    W('f02a');

    p1, p2 = Metakit::IntProp[:p1, :p2]

    Metakit::Storage.open("f02a", 1) {|s1|
      s1.set_structure("a[p1:I],b[p2:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);

      v2 = s1.view("b");
      v2.add(p2[345]);
      v2.add(p2[567]);

      s1.commit();
    }
    
    Metakit::Storage.open("f02a", 1) {|s1|
      s1.set_structure("b[p2:I]");

      v1 = s1.view("a");
      assert_equal 1, v1.get_size()  #// 19990916 new semantics, still as temp view
      assert_equal 123, p1.get(v1[0])

      v2 = s1.view("b");
      assert_equal 2, v2.get_size
      assert_equal 345, p2.get(v2[0])
      assert_equal 567, p2.get(v2[1])

      s1.commit();
    }
    
    Metakit::Storage.open("f02a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 0, v1.get_size

      v2 = s1.view("b");
      assert_equal 2, v2.get_size
      assert_equal 345, p2.get(v2[0])
      assert_equal 567, p2.get(v2[1])
    }

    # D(f02a);
    R('f02a');
  end

  def test_f03_Rollback_format_change
    W('f03a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("f03a", 1) {|s1|
      s1.set_structure("a[p1:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);

      s1.commit();

      v1 = s1.get_as("a");
      assert_equal 0, v1.get_size

      s1.rollback();

      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])
    }

    #D(f03a);
    R('f03a');
  end

  def test_f04_Rearrange_format
    W('f04a');

    p1, p2 = Metakit::IntProp[:p1, :p2]

    Metakit::Storage.open("f04a", 1) {|s1|
      s1.set_structure("a[p1:I],b[p2:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);

      v2 = s1.view("b");
      v2.add(p2[345]);
      v2.add(p2[567]);

      s1.commit();
    }

    Metakit::Storage.open("f04a", 1) {|s1|
      s1.set_structure("b[p2:I],a[p1:I]");

      v1 = s1.view("a");
      assert_equal 1, v1.get_size()
      assert_equal 123, p1.get(v1[0])

      v2 = s1.view("b");
      assert_equal 2, v2.get_size
      assert_equal 345, p2.get(v2[0])
      assert_equal 567, p2.get(v2[1])

      s1.commit();
    }

    #   D(f04a);
    R('f04a');
  end

  def test_f05_Nested_reformat
    W('f05a');

    p1, p2 = Metakit::IntProp[:p1, :p2]

    Metakit::Storage.open("f05a", 1) {|s1|
      s1.set_structure("a[p1:I],b[p2:I]");

      v1 = s1.view("a");
      v1.add(p1[123]);

      v2 = s1.view("b");
      v2.add(p2[345]);
      v2.add(p2[567]);

      s1.commit();
    }
    
    Metakit::Storage.open("f05a", 1) {|s1|
      s1.set_structure("a[p1:I],b[p1:I,p2:I]");

      v2 = s1.view("b");
      p1.set(v2[0], 543)
      p1.set(v2[1], 765)

      s1.commit();
    }

    Metakit::Storage.open("f05a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])

      v2 = s1.view("b");
      assert_equal 2, v2.get_size
      assert_equal 543, p1.get(v2[0])
      assert_equal 765, p1.get(v2[1])
      assert_equal 345, p2.get(v2[0])
      assert_equal 567, p2.get(v2[1])
    }

    #   D(f05a);
    R('f05a');
  end

  def test_f07_Automatic_structure_info_obsolete_
    W('f07a');

#     /* Structure() and Store() are no longer supported
#     c4_StringProp p1 ("p1"), p2 ("p2");
#     c4_Row r1 = p1 ["One"] + p2 ["Two"];
#     c4_Row r2;
#     c4_View v1;
#     v1.Add(r1);
#     v1.Add(r2);
#     v1.Add(r1);

#     c4_View v2 = v1.Structure();
#     A(v2.GetSize() == 1);

#     c4_ViewProp pView ("view");
#     c4_View v3 = pView (v2[0]);
#     A(v3.GetSize() == 2);
#      */
    
# #define FORMAT07 "dict[parent:I,index:I,view[name:S,type:S,child:I]]"
    Metakit::Storage.open("f07a", 1) {|s1|
      s1.set_structure("dict[parent:I,index:I,view[name:S,type:S,child:I]]");

      #     //s1.View("dict") = v1.Structure();

      s1.commit();
    }
    #   D(f07a);
    R('f07a');
  end

  def test_f08_Automatic_storage_format
    W('f08a');

    p1, p2 = Metakit::StringProp[:p1, :p2]
    r1 = p1["One"] + p2["Two"];
    r2 = Metakit::Row.new
    v1 = Metakit::View.new
    v1.add(r1);
    v1.add(r2);
    v1.add(r1);

    Metakit::Storage.open("f08a", 1) {|s1|
      #// changed 2000-03-15: Store is gone
      #//s1.Store("dict", v1);
      v2 = s1.get_as("dict[p1:S,p2:S]");
      v2.insert_view_at(0, v1);
      s1.commit();
    }

    # D(f08a);
    R('f08a');
  end

  def test_f09_Partial_restructuring
    W('f09a');

    p1, p2, p3 = Metakit::IntProp[:p1, :p2, :p3]
    Metakit::Storage.open("f09a", 1) {|s1|

      v1 = s1.get_as("a[p1:I]");
      v1.set_size(10);

      i = 0;
      while i < v1.get_size
        p1.set v1[i], 1000+i
        i += 1
      end

      v2 = s1.get_as("a[p1:I,p2:I]");

      j = 0;
      while j < v2.get_size
        p2.set v2[j], 2000+j
        j += 2
      end

      v3 = s1.get_as("a[p1:I,p2:I,p3:I]");

      k = 0;
      while k < v3.get_size
        p3.set(v3[k], 3000+k)
        k += 3
      end

      s1.commit
    }

      # D(f09a);
    R('f09a');
  end

  def test_f10_Committed_restructuring
    W('f10a');

    p1, p2, p3 = Metakit::IntProp[:p1, :p2, :p3]
    Metakit::Storage.open("f10a", 1) {|s1|

      v1 = s1.get_as("a[p1:I]");
      v1.set_size(10);

      i = 0
      while i < v1.get_size()
        p1.set(v1[i], 1000+i)
        i += 1
      end

      s1.commit();

      v2 = s1.get_as("a[p1:I,p2:I]");

      j = 0
      while j < v2.get_size()
        p2.set(v2[j], 2000+j)
        j += 2
      end

      s1.commit();
      
      v3 = s1.get_as("a[p1:I,p2:I,p3:I]");

      k = 0
      while k < v3.get_size
        p3.set(v3[k], 3000+k)
        k += 3
      end

      s1.commit();
    }
    # D(f10a);
    R('f10a');
  end

  #// 19990824: don't crash on GetAs with an inexistent view
  def test_f11_Delete_missing_view
    W('f11a');

    Metakit::Storage.open("f11a", 1) {|s1|
      v1 = s1.get_as("a");
      v1.set_size(10);

      s1.commit();
    }
    #   D(f11a);
    R('f11a');
  end
end
