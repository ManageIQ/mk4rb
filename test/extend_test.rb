require 'mk4rb_test_helper'

# These tests are adapted from :
#// textend.cpp -- Regression test program, commit extend tests
#// $Id: textend.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class ExtendTest < MetakitBaseTest
  KSize1 = 41;
  KSize2 = 85;

  def test_e01_Extend_new_file
    W("e01a");

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("e01a", 2) {|s1|
      assert_equal 0, s1.strategy.file_size

      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
      assert_equal KSize1, s1.strategy.file_size

      v1.add(p1[456]);
      s1.commit();
      assert_equal KSize2, s1.strategy.file_size
    }

    #D(e01a);
    R("e01a");
  end

  def test_e02_Extend_committing_twice
    W('e02a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("e02a", 2) {|s1|
      assert_equal 0, s1.strategy.file_size
      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
      assert_equal KSize1, s1.strategy.file_size
      s1.commit();
      assert_equal KSize1, s1.strategy.file_size
      v1.add(p1[456]);
      s1.commit();
      assert_equal KSize2, s1.strategy.file_size
    }
    #   D(e02a);
    R("e02a");
  end

  def test_e03_Read_during_extend
    W('e03a');

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("e03a", 2) {|s1|
      assert_equal 0, s1.strategy.file_size
      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
      assert_equal KSize1, s1.strategy.file_size

      Metakit::Storage.open("e03a", 0) {|s2|
        v2 = s2.view("a");
        assert_equal 1, v2.get_size
        assert_equal 123, p1.get(v2[0])
      }

      v1.add(p1[456]);
      s1.commit();
      assert_equal KSize2, s1.strategy.file_size

      Metakit::Storage.open("e03a", 0) {|s3|
        v3 = s3.view("a");
        assert_equal 2, v3.get_size
        assert_equal 123, p1.get(v3[0])
        assert_equal 456, p1.get(v3[1])
      }
    }

    #D(e03a);
    R('e03a');
  end

  def test_e04_Extend_during_read
    W('e04a');
    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("e04a", 2) {|s1|
      assert_equal 0, s1.strategy().file_size
      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
      assert_equal KSize1, s1.strategy().file_size
    }

    Metakit::Storage.open("e04a", 0) {|s2|
      v2 = s2.view("a");
      assert_equal 1, v2.get_size
      assert_equal 123, p1.get(v2[0])

      Metakit::Storage.open("e04a", 0) {|s3| #; { // open, don't load
    
        Metakit::Storage.open("e04a", 2) {|s4|
          assert_equal KSize1, s4.strategy().file_size
          v4 = s4.view("a");
          v4.add(p1[123]);
          s4.commit();
          assert (s4.strategy().file_size() > KSize1) #; // == kSize2);
        }

        v2a = s2.view("a");
        assert_equal 1, v2a.get_size
        assert_equal 123, p1.get(v2a[0])

        v3 = s3.view("a");
        assert_equal 1, v3.get_size
        assert_equal 123, p1.get(v3[0])
      }
    }
    #   D(e04a);
    R('e04a');
  end
  
  def test_e06_Rollback_during_extend
    W('e06a');
    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("e06a", 2) {|s1|
      assert_equal 0, s1.strategy().file_size
      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
      assert_equal KSize1, s1.strategy().file_size

      Metakit::Storage.open("e06a", 0) {|s2|
        v2 = s2.view("a");
        assert_equal 1, v2.get_size
        assert_equal 123, p1.get(v2[0])

        v1.add(p1[456]);
        s1.commit();
        assert_equal KSize2, s1.strategy().file_size
        
# #if 0
#     /* fails on NT + Samba, though it works fine with mmap'ing disabled */
#     s2.Rollback();

#     c4_View v2a = s2.View("a");
#     A(v2a.GetSize() == 2);
#     A(p1(v2a[0]) == 123);
#     A(p1(v2a[1]) == 456);
# #else 
        v2a = s2.view("a");
        assert_equal 1, v2a.get_size
        assert_equal 123, p1.get(v2a[0])
# #endif 
      }
    }
    # D(e06a);
    R('e06a');
  end
end
