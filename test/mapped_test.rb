require 'mk4rb_test_helper'

# These tests are adapted from: 
#// tmapped.cpp -- Regression test program, mapped view tests
#// $Id: tmapped.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class MappedTest < MetakitBaseTest

  def TestBlockDel(pos_, len_)
    printf("blockdel pos %d len %d\n", pos_, len_);

    p1 = Metakit::ViewProp.new("_B");
    p2 = Metakit::IntProp.new("p2");

    Metakit::Storage.create {|s1|
      v1 = s1.get_as("v1[_B[p2:I]]");

      n = 0;
      sizes = [999, 999, 999, 2]

      sizes.each {|size|
        v = Metakit::View.new
        v.set_size(size);
        j = 0
        while j < size
          n += 1
          p2.set(v[j], n)
          j += 1
        end
        v1.add(p1[v]);
      }

      v2 = v1.blocked
      assert_equal 2999, v2.get_size

      v2.remove_at(pos_, len_);
      assert_equal 2999-len_, v2.get_size
    }
  end

  def test_m01_Hash_mapping
    p1 = Metakit::StringProp.new("p1");

    Metakit::Storage.create {|s1|
      v1 = s1.get_as("v1[p1:S]");
      v2 = s1.get_as("v2[_H:I,_R:I]");
      v3 = v1.hash(v2, 1);

      v3.add(p1["b93655249726e5ef4c68e45033c2e0850570e1e07"]);
      v3.add(p1["2ab03fba463d214f854a71ab5c951cea096887adf"]);
      v3.add(p1["2e196eecb91b02c16c23360d8e1b205f0b3e3fa3d"]);
      assert_equal 3, v3.get_size

      #// infinite loop in 2.4.0, reported by Nathan Rogers, July 2001
      #// happens when looking for missing key after a hash collision
      f = v3.find(p1["7c0734c9187133f34588517fb5b39294076f22ba3"]);
      assert_equal  -1, f
    }
  end

  #// example from Steve Baxter, Nov 2001, after block perf bugfix
  #// assertion failure on row 1001, due to commit data mismatch
  def test_m02_Blocked_view_bug
    W('m02a');

    p1 = Metakit::BytesProp.new("p1");
    h  = Metakit::Bytes.default_new

    Metakit::Storage.open("m02a", 1) {|s1|
      v1 = s1.get_as("v1[_B[p1:B]]");
      v2 = v1.blocked();

      i = 0
      while i < 1005 
        h.set_buffer(2500+i);
        v2.add(p1[h]);

        if (i >= 999)
          # // will crash a few rounds later, at row 1001
          s1.commit();
        end
        i += 1
      end

      # // reduce size to shorten the dump output
      v2.remove_at(0, 990);
      s1.commit();
    }

    #D(m02a);
    R('m02a');
  end
  
  def test_m03_Hash_adds_0
    W('m03a');

    p1 = Metakit::StringProp.new("p1");

    Metakit::Storage.open("m03a", 1) {|s1|

      d1 = s1.get_as("d1[p1:S]");
      m1 = s1.get_as("m1[_H:I,_R:I]");
      h1 = d1.hash(m1);

      h1.add(p1["one"]);
      s1.commit();

      d2 = s1.get_as("d2[p1:S]");
      m2 = s1.get_as("m2[_H:I,_R:I]");
      h2 = d2.hash(m2);

      h1.add(p1["two"]);
      h2.add(p1["two"]);
      s1.commit();

      d3 = s1.get_as("d3[p1:S]");
      m3 = s1.get_as("m3[_H:I,_R:I]");
      h3 = d3.hash(m3);

      h1.add(p1["three"]);
      h2.add(p1["three"]);
      h3.add(p1["three"]);
      s1.commit();

      d4 = s1.get_as("d4[p1:S]");
      m4 = s1.get_as("m4[_H:I,_R:I]");
      h4 = d4.hash(m4);

      h1.add(p1["four"]);
      h2.add(p1["four"]);
      h3.add(p1["four"]);
      h4.add(p1["four"]);
      s1.commit();
    }
    # D(m03a);
    R('m03a');
  end

  def test_m04_Locate_bug
    W('m04a');

    p1 = Metakit::IntProp.new("p1");
    p2 = Metakit::StringProp.new("p2");

    Metakit::Storage.open("m04a", 1) {|s1|
      s1.autocommit

      v1 = s1.get_as("v1[p1:I,p2:S]");

      v1.add(p1[1] + p2["one"]);
      v1.add(p1[2] + p2["two"]);
      v1.add(p1[3] + p2["three"]);
      s1.commit();

      v2 = v1.ordered();
      assert_equal 3, v2.get_size
      v2.add(p1[6] + p2["six"]);
      v2.add(p1[5] + p2["five"]);
      v2.add(p1[4] + p2["four"]);
      assert_equal 6, v2.get_size
      assert_equal 6, v1.get_size

      assert_equal 1, p1.get(v1[0])
      assert_equal 2, p1.get(v1[1])
      assert_equal 3, p1.get(v1[2])
      assert_equal 4, p1.get(v1[3])
      assert_equal 5, p1.get(v1[4])
      assert_equal 6, p1.get(v1[5])

      assert_equal 3, v2.find(p1[4])
      assert_equal 3, v2.search(p1[4])

      i1 =  - 1;
      n, i1 = v1.locate(p1[4])
      assert_equal 1, n
      assert_equal 3, i1

      i2 =  - 1;
      n, i2  = v2.locate(p1[4])
      assert_equal 1, n
      assert_equal 3, i2
    }
    #D(m04a);
    R('m04a');
  end

  # // subviews are not relocated properly with blocked views in 2.4.7
  def test_m05_Blocked_view_with_subviews
    W('m05a');

    p1 = Metakit::StringProp.new("p1");
    p2 = Metakit::IntProp.new("p2");
    pSv = Metakit::ViewProp.new("sv");

    Metakit::Storage.open("m05a", 1) {|s1|
      v1 = s1.get_as("v1[_B[p1:S,sv[p2:I]]]");
      v2 = v1.blocked();

      1000.times {|i|
        buf = "id-#{i}"
        v2.add(p1[buf]);

        v3 = pSv.get(v2[i]);
        v3.add(p2[i]);
      }

      1.times {|j|
        buf = "insert-#{j}"
        v2.insert_row_at(500, p1[buf]);
      }

      s1.commit();
    }
    # D(m05a);
    R('m05a');
  end

  # // 2003/02/14 - assert fails for 2.4.8 in c4_Column::RemoveData
  def test_m06_Blocked_view_multi_row_deletion
    W('m06a');

    p1 = Metakit::IntProp.new("p1");

    Metakit::Storage.open("m06a", 1) {|s1|
      v1 = s1.get_as("v1[p1:I]");
      v2 = s1.get_as("v2[_B[_H:I,_R:I]]");
      v3 = v2.blocked();
      v4 = v1.hash(v3, 1);

      v4.add(p1[1]);
      v4.add(p1[2]);
      v4.remove_at(1);

      i = 100
      while i < 1000
        v4.add(p1[i])
        i += 1
      end

      s1.commit();
    }

    #D(m06a);
    R('m06a');
  end

  # // 2003/03/07 - still not correct on blocked veiw deletions
  def test_m07_All_blocked_view_multi_deletion_cases

    (0...2).each {|i|
      (1...4).each {|j|
        TestBlockDel(i, j);
      }
      (998...1002).each {|j|
        TestBlockDel(i, j);
      }
      
      (1998...2002).each {|j|
        TestBlockDel(i, j);
      }
    }
    
    (998...1002).each {|i|
      (1...4).each {|j|
        TestBlockDel(i, j);
      }
      (998...1002).each {|j|
        TestBlockDel(i, j);
      }
    }
    
    (1...4).each {|i|
      TestBlockDel(2999-i, i)
    }
    (998...1002).each {|i|
      TestBlockDel(2999-i, i)
    }
    (1998...2002).each {|i|
      TestBlockDel(2999-i, i)
    }
  end
end
