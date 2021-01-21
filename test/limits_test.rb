require 'mk4rb_test_helper'

# These tests are adapted from: 
# // tlimits.cpp -- Regression test program, limit tests
# // $Id: tlimits.cpp 1230 2007-03-09 15:58:53Z jcw $
# // This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class LimitsTest < MetakitBaseTest
  
  def test_l00_Lots_of_properties
    W('l00a');

    desc = ""
    150.times {|i|
      desc += ",p#{i+1}:I"
    }
    
    desc = "a[" + desc[1..-1] + "]";

    Metakit::Storage.open("l00a", 1) {|s1|
      s1.set_structure(desc);
      v1 = s1.view("a");
      p123 = Metakit::IntProp.new("p123");
      v1.add(p123[123]);
      s1.commit();
    }
    # D(l00a);
    R('l00a');
  end

  def test_l01_Over_32_Kb_of_integers
    W('l01a');

    Metakit::Storage.open("l01a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      p1 = Metakit::IntProp.new("p1");
      v1.set_size(9000);

      i = 0
      while i < v1.get_size
        p1.set(v1[i], 1000000 + i)
        assert_equal(i, p1.get(v1[i]) - 1000000)
        i += 1
      end
      
      j = 0;
      while j < v1.get_size();
        assert_equal j, p1.get(v1[j]) - 1000000
        j += 1
      end

      s1.commit();

      k = 0
      while k < v1.get_size
        assert_equal k, p1.get(v1[k]) - 1000000
        k += 1
      end
    }

    #D(l01a);
    R('l01a');
  end
  
  def test_l02_Over_64_Kb_of_strings
    W('l02a');

    texts = [
             "Alice in Wonderland", "The wizard of Oz", "I'm singin' in the rain"
             ]
    
    Metakit::Storage.open("l02a", 1) {|s1|
      s1.set_structure("a[p1:S]");
      v1 = s1.view("a");
      
      p1 = Metakit::StringProp.new("p1");
      r1 = Metakit::Row.new

      i = 0
      while i < 3500
        p1.set(r1, texts[i % 3])
        v1.add(r1);

        assert_equal texts[i % 3], p1.get(v1[i])
        
        i += 1
      end

      j = 0
      while j < v1.get_size
        assert_equal texts[j % 3], p1.get(v1[j])
        j += 1
      end

      s1.commit();

      k = 0
      while k < v1.get_size
        assert_equal texts[k % 3], p1.get(v1[k])
        k += 1
      end
    }

      #D(l02a);
      R('l02a');
    end

  def test_l03_Forcesections_in_storage
    W('l03a');
    W('l03b');

    p1 = Metakit::ViewProp.new("p1");
    p2 = Metakit::IntProp.new("p2");

    Metakit::Storage.open("l03a", 1) {|s1|
      s1.set_structure("a[p1[p2:I]]");
      v1 = s1.view("a");

      v2 = Metakit::View.new
      v2.set_size(1);

      i = 0
      while i < 500 
        p2.set(v2[0], 9000+i)
        v1.add(p1[v2]);
        i += 1
      end

      s1.commit();
    }

    Metakit::Storage.open("l03a", 0) {|s1|
      v1 = s1.view("a");

      i = 0
      while i < 500
        v2 = p1.get(v1[i])
        assert_equal 9000+i, p2.get(v2[0])
        i += 1
      end

      Metakit::FileStream.open("l03b", "wb") {|fs1|
        s1.save_to(fs1);
      }
    }
    
    
    Metakit::Storage.create {|s1|
      Metakit::FileStream.open("l03b", "rb") {|fs1|
        s1.load_from(fs1);

        v1 = s1.view("a");

        i = 0
        while i < 500
          v2 = p1.get(v1[i])
          assert_equal 9000+i, p2.get(v2[0])
          i += 1
        end
      }
    }

    #D(l03a);
    #D(l03b);
    R('l03a');
    R('l03b');
  end

  def test_l04_Modify_sections_in_storage
    W('l04a');

    p1 = Metakit::ViewProp.new("p1");
    p2 = Metakit::IntProp.new("p2");

    Metakit::Storage.open("l04a", 1) {|s1|
      s1.set_structure("a[p1[p2:I]]");
      v1 = s1.view("a");

      v2 = Metakit::View.new
      v2.set_size(1);

      i = 0
      while i < 500
        p2.set(v2[0], 9000+i)
        v1.add(p1[v2])
        i += 1
      end

      s1.commit();
    }
    
    Metakit::Storage.open("l04a", 1) {|s1|
      v1 = s1.view("a");
      v2 = p1.get(v1[0]);

      p2.set(v2[0], 1)
      # // this corrupted file in 1.5: free space was bad after load
      s1.commit();
    }
    
    Metakit::Storage.open("l04a", 0) do 
    end

    #D(l04a);
    R('l04a');
  end

  def test_l05_Delete_from_32_Kb_of_strings
    W('l05a');

    texts = ["Alice in Wonderland", "The wizard of Oz", "I'm singin' in the rain"]

    Metakit::Storage.open("l05a", 1) {|s1|
      s1.set_structure("a[p1:I,p2:S,p3:S]");
      v1 = s1.view("a");
      p1 = Metakit::IntProp.new("p1");
      p2, p3 = Metakit::StringProp[:p2, :p3]
      r1 = Metakit::Row.new

      i = 0
      while i < 1750 
        p1.set(r1, i)
        p2.set(r1, texts[i % 3])
        p3.set(r1, texts[i % 3])
        v1.add(r1);

        assert_equal texts[i % 3], p2.get(v1[i])
        i += 1
      end

      j = 0
      while j < v1.get_size
        assert_equal j, p1.get(v1[j])
        assert_equal texts[j % 3], p2.get(v1[j])
        assert_equal texts[j % 3], p3.get(v1[j])
        j += 1
      end

      s1.commit();

      while (v1.get_size > 1)
        # // randomly remove entries
        # (unsigned short)
        v1.remove_at((211 * v1.get_size) % v1.get_size)
      end

      s1.commit
    }
    # D(l05a);
    R('l05a');
  end

  def test_l06_Bit_field_manipulations
    W('l06a');

    p1 = Metakit::IntProp.new("p1");
    v2 = Metakit::View.new

    Metakit::Storage.open("l06a", 1) {|s1|
      s1.set_structure("a[p1:I]");
      v1 = s1.view("a");
      r1 = Metakit::Row.new

      i = 2
      while i <= 256
        j = 0
        while j < 18
          p1.set(r1, j &(i - 1));

          v1.insert_row_at(j, r1, j + 1);
          v2.insert_row_at(j, r1, j + 1);
          j += 1
        end

        s1.commit();
        i <<= 1
      end
    }
    
    Metakit::Storage.open("l06a", 0) {|s1|
      v1 = s1.view("a");

      n = v2.get_size
      assert_equal n, v1.get_size

      i = 0
      while i < n
        v = p1.get(v2[i])
        assert_equal v, p1.get(v1[i])
        i += 1
      end
    }

    #D(l06a);
    R('l06a');
  end

  def test_l07_Huge_description
    W('l07a');

    desc = ""

    150.times {|i|
      #// 1999-07-25: longer size to force over 4 Kb of description
      desc += ",a123456789a123456789a123456789p#{i+1}:I"
    }

    desc = "a[" + desc[1..-1] + "]";

    Metakit::Storage.open("l07a", 1) {|s1|
      s1.set_structure(desc);
      v1 = s1.view("a");
      p123 = Metakit::IntProp.new("p123");
      v1.add(p123[123]);
      s1.commit();
    }

    #D(l07a);
    R('l07a');
  end
end
