require 'mk4rb_test_helper'

# These tests are adapted from :
#// tdiffer.cpp -- Regression test program, differential commit tests
#// $Id: tdiffer.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class DifferTest < MetakitBaseTest

  def test_d01_Commit_aside
    W("d01a");
    W("d01b");

    p1 = Metakit::IntProp.new("p1");
    Metakit::Storage.open("d01a", 1) {|s1|
      assert_equal 0, s1.strategy.file_size
      v1 = s1.get_as("a[p1:I]");
      v1.add(p1[123]);
      s1.commit();
    }

    Metakit::Storage.open("d01a", 0) {|s1|
      Metakit::Storage.open("d01b", 1) {|s2|
        s1.set_aside(s2);
        
        v1 = s1.view("a");
        assert_equal 1, v1.get_size
        assert_equal 123, p1.get(v1[0])
        v1.add(p1[456]);

        assert_equal 2, v1.get_size
        assert_equal 123, p1.get(v1[0])
        assert_equal 456, p1.get(v1[1])
        s1.commit();
        
        assert_equal 2, v1.get_size
        assert_equal 123, p1.get(v1[0])
        assert_equal 456, p1.get(v1[1])
        s2.commit();
        assert_equal 2, v1.get_size
        assert_equal 123, p1.get(v1[0])
        assert_equal 456, p1.get(v1[1])
      }
    }

    Metakit::Storage.open("d01a", 0) {|s1|
      v1 = s1.view("a");
      assert_equal 1, v1.get_size
      assert_equal 123, p1.get(v1[0])

      Metakit::Storage.open("d01b", 0) {|s2|
        s1.set_aside(s2);
        v2 = s1.view("a");
        assert_equal 2, v2.get_size
        assert_equal 123, p1.get(v2[0])
        assert_equal 456, p1.get(v2[1])
      }
    }

    #  D(d01a);
    #  D(d01b);
    R("d01a");
    R("d01b");
  end
end
