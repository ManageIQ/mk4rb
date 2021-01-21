require 'mk4rb_test_helper'

# These tests are adapted from :
#// tstore3.cpp -- Regression test program, storage tests, part 3
#// $Id: tstore3.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Store3_Test < MetakitBaseTest
  def test_s20_View_outlives_storage
    W('s20a');

    p1 = Metakit::IntProp.new("p1");
    v1 = Metakit::View.new

    Metakit::Storage.open("s20a", 1) {|s1|
      v1 = s1.get_as("a[p1:I,p2:S]");
      v1.add(p1[123]);
    }

    #// 19990916 - semantics changed, rows kept but no properties
    # //A(p1 (v1[0]) == 123);
    assert_equal 1, v1.get_size
    assert_equal 0, v1.num_properties

    #D('s20a');
    R('s20a');
  end

  def test_s21_Test_demo_scenario
    W('s21a');

    p1, p2 = Metakit::StringProp[:p1, :p2]
    Metakit::Storage.open("s21a", 1) {|storage|
      storage.set_structure("a[p1:S,p2:S]");
      v1 = Metakit::View.new;
      r1 = Metakit::Row.new

      p1.set(r1,  "One")
      p2.set(r1,  "Un")
      v1.add(r1);
      assert_equal 1, v1.get_size()

      p1.set(r1, "Two")
      p2.set(r1, "Deux")
      v1.add(r1);
      assert_equal 2, v1.get_size()

      #// changed 2000-03-15: Store is gone
      #//v1 = storage.Store("a", v1);
      v1 = storage.view_and_assign("a", v1)

      assert_equal 2, v1.get_size
      assert_equal "Two", p1.get(v1[1])
      assert_equal "Deux", p2.get(v1[1])
      assert_equal "One", p1.get(v1[0])
      assert_equal "Un", p2.get(v1[0])

      storage.commit();
      assert_equal 2, v1.get_size
      assert_equal "Two", p1.get(v1[1])
      assert_equal "Deux", p2.get(v1[1])
      assert_equal "One", p1.get(v1[0])
      assert_equal "Un", p2.get(v1[0])

      s1 = p1.get(v1[1])
      s2 = p2.get(v1[1])
      assert_equal "Two", s1
      assert_equal "Deux", s2

      storage.commit();

      v1.add(p1["Three"] + p2["Trois"]);

      storage.commit();
      assert_equal 3, v1.get_size
      assert_equal "Trois", p2.get(v1[2])

      v1 = storage.get_as("a[p1:S,p2:S,p3:I]");
      assert_equal 3, v1.get_size
      assert_equal "Trois", p2.get(v1[2])

      p3 = Metakit::IntProp.new("p3");
      p3.set(v1[1], 123)

      storage.commit();
      assert_equal 3, v1.get_size()
      assert_equal "Trois", p2.get(v1[2])

      v2 = storage.get_as("b[p4:I]");

      p4 = Metakit::IntProp.new("p4");
      v2.add(p4[234]);

      storage.commit();
      assert_equal 3, v1.get_size
      assert_equal "Trois", p2.get(v1[2])

      p4a = Metakit::IntProp.new("p4");
      v1.insert_row_at(2, p1["Four"] + p4a[345]);

      storage.commit();
      assert_equal 4, v1.get_size()
      assert_equal "One", p1.get(v1[0])
      assert_equal "Two", p1.get(v1[1])
      assert_equal "Four", p1.get(v1[2])
      assert_equal "Three", p1.get(v1[3])
      assert_equal "Trois", p2.get(v1[3])
      assert_equal 1, v2.get_size
      assert_equal 234, p4.get(v2[0])
    }
    
    Metakit::Storage.open("s21a", 0) {|storage|
      v1 = storage.view("a");
      assert_equal 4, v1.get_size()
      assert_equal "One", p1.get(v1[0])
      assert_equal "Two", p1.get(v1[1])
      assert_equal "Four", p1.get(v1[2])
      assert_equal "Three", p1.get(v1[3])
      v2 = storage.view("b");
      p4 = Metakit::IntProp.new("p4");
      assert_equal 1, v2.get_size
      assert_equal 234, p4.get(v2[0])
    }

    #D(s21a);
    R('s21a');
  end

  def test_s22_Double_storage
    W('s22a');

    p1 = Metakit::DoubleProp.new("p1");
    Metakit::Storage.open("s22a", 1) {|s1|
      s1.set_structure("a[p1:D]");
      v1 = s1.view("a");
      v1.add(p1[1234.5678]);
      v1.add(p1[2345.6789]);
      v1.insert_row_at(1, p1[3456.7890]);
      s1.commit();
    }
    #D(s22a);
    R('s22a');
  end

  def test_s23_Find_absent_record
    W('s23a');

    Metakit::Storage.open("s23a", 1) {|s1|
      s1.set_structure("v[h:S,p:I,a:I,b:I,c:I,d:I,e:I,f:I,g:I,x:I]");
      view = s1.view("v");

      h = Metakit::StringProp.new("h");
      p = Metakit::IntProp.new("p");

      row = Metakit::Row.new
      h.set(row, "someString")
      p.set(row, 99)

      x = view.find(row);
      assert_equal x, - 1
    }
    #D(s23a);
    R('s23a');
  end

  def test_s24_Bitwise_storage
    W('s24a');

    p1 = Metakit::IntProp.new("p1");

    m = 9;

    #// insert values in front, but check fractional sizes at each step
    m.times {|n|

      Metakit::Storage.open("s24a", 1) {|s1|
        s1.set_structure("a1[p1:I],a2[p1:I],a3[p1:I],a4[p1:I]");
        s1.autocommit();# // new feature in 1.6

        v1 = s1.view("a1");
        v2 = s1.view("a2");
        v3 = s1.view("a3");
        v4 = s1.view("a4");

        row = Metakit::Row.new
        k = ~n;

        p1.set(row, k &0x01)
        v1.insert_row_at(0, row);

        p1.set(row, k &0x03)
        v2.insert_row_at(0, row);

        p1.set(row, k &0x0F)
        v3.insert_row_at(0, row);

        p1.set(row, k &0x7F)
        v4.insert_row_at(0, row);
      }
      
      #// the following checks that all tiny size combinations work
      Metakit::Storage.open("s24a", 0) {|s1|
        v1 = s1.view("a1");
        v2 = s1.view("a2");
        v3 = s1.view("a3");
        v4 = s1.view("a4");

        assert_equal n + 1, v1.get_size
        assert_equal n + 1, v2.get_size
        assert_equal n + 1, v3.get_size
        assert_equal n + 1, v4.get_size
      }
    }

    Metakit::Storage.open("s24a", 0) {|s1|

      v1 = s1.view("a1");
      v2 = s1.view("a2");
      v3 = s1.view("a3");
      v4 = s1.view("a4");

      assert_equal m, v1.get_size()
      assert_equal m, v2.get_size()
      assert_equal m, v3.get_size()
      assert_equal m, v4.get_size()

      #// now check that the inserted values are correct
      m.times {|i|
        j = m - i - 1;
        k = ~i;

        assert_equal(p1.get(v1[j]), (k &0x01))
        assert_equal(p1.get(v2[j]), (k &0x03));
        assert_equal(p1.get(v3[j]), (k &0x0F));
        assert_equal(p1.get(v4[j]), (k &0x7F));
      }
    }
    
    #D(s24a);
    R('s24a');
  end

  def test_s25_Bytes_storage
    W('s25a');

    hi = Metakit::Bytes.new("hi", 2);
    gday = Metakit::Bytes.new("gday", 4);
    hello = Metakit::Bytes.new("hello", 5);

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s25a", 1) {|s1|
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
    #D(s25a);
    R('s25a');
  end

  def test_s26_Bitwise_autosizing
    W('s26a');

    p1, p2, p3, p4 = Metakit::IntProp[:p1, :p2, :p3, :p4]
    Metakit::Storage.open("s26a", 1) {|s1|
      s1.set_structure("a[p1:I,p2:I,p3:I,p4:I]");
      v1 = s1.view("a");

      v1.add(p1[1] + p2[3] + p3[15] + p4[127]);
      assert_equal 1, p1.get(v1[0])
      assert_equal 3, p2.get(v1[0])
      assert_equal 15, p3.get(v1[0])
      assert_equal 127, p4.get(v1[0])

      p1.set(v1[0], 100000)
      p2.set(v1[0], 100000)
      p3.set(v1[0], 100000)
      p4.set(v1[0], 100000)

      #// these failed in 1.61
      assert_equal 100000, p1.get(v1[0])
      assert_equal 100000, p2.get(v1[0])
      assert_equal 100000, p3.get(v1[0])
      assert_equal 100000, p4.get(v1[0])

      s1.commit();
    }
    #D(s26a);
    R('s26a');
  end

  def test_s27_Bytes_restructuring
    W('s27a');

    test = Metakit::Bytes.new("test", 4);

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("s27a", 1) {|s1|

      row = Metakit::Row.new
      p1.set(row, test)

      v1 = Metakit::View.new
      v1.add(row);

      #// changed 2000-03-15: Store is gone
      #//s1.Store("a", v1); // asserts in 1.61
      v2 = s1.get_as("a[p1:B]");
      v2.insert_view_at(0, v1);

      s1.commit();
    }
    #D(s27a);
    R('s27a');
  end

  def test_s28_Doubles_added_later
    W('s28a');

    p1 = Metakit::FloatProp.new("p1");
    p2 = Metakit::DoubleProp.new("p2");
    p3 = Metakit::ViewProp.new("p3");

    Metakit::Storage.open("s28a", 1) {|s1|
      s1.set_structure("a[p1:F,p2:D,p3[p1:F,p2:D]]");
      v1 = s1.view("a");

      r1 = Metakit::Row.new

      p1.set(r1, 123)
      p2.set(r1, 123)

      v2 = Metakit::View.new
      v2.add(p1[234] + p2[234]);
      p3.set(r1, v2)

      v1.add(r1);
      x1 = p1.get(v1[0]);
      assert_equal x1, p2.get(v1[0])

      v2 = p3.get(v1[0]);
      x2 = p1.get(v2[0]);
      assert_equal x2, p2.get(v2[0]) # // fails in 1.6

      s1.commit();
    }
    #D(s28a);
    R('s28a');
  end

  def test_s29_Delete_bytes_property
    W('s29a');

    Metakit::Storage.open("s29a", 1) {| s1|
      p1 = Metakit::BytesProp.new("p1");
      s1.set_structure("a[p1:B]");
      v1 = s1.view("a");

      data = "\x63\x00\x00\x00";
      v1.add(p1[Metakit::Bytes.new(data, 4)]);

      s1.commit();
    }

    Metakit::Storage.open("s29a", 1) {|s1|
      v1 = s1.view("a");

      v1.remove_at(0); #// asserts in 1.7

      s1.commit();
    }

    #D(s29a);
    R('s29a');
  end
end
