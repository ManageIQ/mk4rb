require 'mk4rb_test_helper'

# These tests are adapted from :
#// trseize.cpp -- Regression test program, resizing tests
#// $Id: tresize.cpp 1230 2007-03-09 15:58:53Z jcw $
#// This is part of Metakit, the homepage is http://www.equi4.com/metakit.html

class Resizer 
  include Test::Unit::Assertions
  
  KMaxData = 15000
  
  def self.open file, test
    s = new file, test
    begin
      yield s
    ensure
      s.close!
    end
  end
  
  def initialize file, test
    @storage = Metakit::Storage.new file, 1
    @refSize = 0
    @prop    = Metakit::IntProp.new("p1")
    @seed    = 0 
    @test    = test

    @storage.set_structure("a[p1:I]");

    @refData = Array.new KMaxData

    @attached = @storage.view("a");
    @unattached = Metakit::View.new

    verify
  end
  
  attr_reader :storage

  def close!
    verify
    @storage.commit
    verify

    @storage.close!
  end      

  def add_assertion
    @test.send :add_assertion
  end
  
  def verify
    assert_equal @refSize, @unattached.get_size
    assert_equal @refSize, @attached.get_size

    @refSize.times {|i|
      assert_equal @refData[i], @prop.get(@unattached[i])
      assert_equal @refData[i], @prop.get(@attached[i])
    }
  end

  def ins pos, cnt
    assert(pos <= @refSize)
    assert(@refSize + cnt < KMaxData)

    #memmove(_refData + pos_ + cnt_, _refData + pos_, _refSize - pos_);
    @refData[pos+cnt, @refSize - pos] = @refData[pos, @refSize - pos]

    @refSize += cnt;

    row = Metakit::Row.new
    @unattached.insert_row_at(pos, row, cnt);
    @attached.insert_row_at(pos, row, cnt);

    cnt.times {|i|
      @seed += 1
      @refData[i + pos] = @seed
      @prop.set(@unattached[i+pos], @seed)
      @prop.set(@attached[i+pos], @seed)

      if (@seed >= 123)
        @seed = 0;
      end
    }

    verify;

    return @refSize;
  end
    
  def del pos, cnt
    assert(pos + cnt <= @refSize)

    @refSize -= cnt
    #memmove(_refData + pos_, _refData + pos_ + cnt_, _refSize - pos_);
    @refData[pos, @refSize - pos] = @refData[pos+cnt, @refSize - pos]

    @unattached.remove_at(pos, cnt);
    @attached.remove_at(pos, cnt);

    verify;
    
    return @refSize;
  end
end

class ResizeTest < MetakitBaseTest

  def test_r00_Simple_insert
    W('r00a');

    Resizer.open "r00a", self do |r1|
      n = r1.ins(0, 250);
      assert_equal 250, n
    end
    # D(r00a);
    R('r00a');
  end

  def test_r01_Simple_removes
    W('r01a');

    Resizer.open "r01a", self do |r1|
      n = r1.ins(0, 500);
      assert_equal 500, n

      n = r1.del(0, 50);
      assert_equal 450, n

      n = r1.del(350, 100);
      assert_equal 350, n

      n = r1.del(25, 150);
      assert_equal 200, n

      n = r1.del(0, 200);
      assert_equal 0, n

      n = r1.ins(0, 15);
      assert_equal 15, n
    end

    #   D(r01a);
    R('r01a');
  end

  def test_r02_Large_inserts_and_removes
    W('r02a');

    #int big = sizeof(int) == sizeof(short) ? 1000 : 4000;
    big = 4000

    Resizer.open("r02a", self) do |r1|
      n = r1.ins(0, 2000);
      assert_equal 2000, n
      n = r1.ins(0, 3000);
      assert_equal 5000, n
      n = r1.ins(5000, 1000+big);
      assert_equal 6000+big, n
      n = r1.ins(100, 10);
      assert_equal 6010+big, n
      n = r1.ins(4000, 100);
      assert_equal 6110+big, n
      n = r1.ins(0, 1001);
      assert_equal 7111+big, n

      n = r1.del(7111, big);
      assert_equal 7111, n
      n = r1.del(0, 4111);
      assert_equal 3000, n
      n = r1.del(10, 10);
      assert_equal 2990, n
      n = r1.del(10, 10);
      assert_equal 2980, n
      n = r1.del(5, 10);
      assert_equal 2970, n
      n = r1.del(0, 990);
      assert_equal 1980, n
      n = r1.del(3, 1975);
      assert_equal 5, n
    end

    #   D(r02a);
    R('r02a');
  end

  def test_r03_Binary_property_insertions
    W('r03a');

    p1 = Metakit::BytesProp.new("p1");
    Metakit::Storage.open("r03a", 1) do |s1|
      s1.set_structure("a[p1:B]");
      v1 = s1.view("a");

      buf = "\x11" * 1024
      v1.add(p1[Metakit::Bytes.new(buf, buf.size)]);

      buf = "\x22" * 1024
      v1.add(p1[Metakit::Bytes.new(buf, buf.size / 2)]);

      s1.commit();

      buf = "\x33" * 1024
      p1.set(v1[1], Metakit::Bytes.new(buf, buf.size)); #// fix c4_Column::CopyData

      buf = "\x44" * 1024
      v1.add(p1[Metakit::Bytes.new(buf, buf.size / 3)]);

      s1.commit();

      buf = "\x55" * 1024
      v1.insert_row_at(1, p1[Metakit::Bytes.new(buf, buf.size)]);

      buf = "\x66" * 1024
      v1.insert_row_at(1, p1[Metakit::Bytes.new(buf, buf.size / 4)]);

      s1.commit();
    end
    
    # D(r03a);
    R('r03a');
  end

  def test_r04_Scripted_string_property_tests
    W('r04a');

    p1 = Metakit::StringProp.new("p1");
    Metakit::Storage.open("r04a", 1) do |s1|
      s1.set_structure("a[p1:S]");

      #     // This code implements a tiny language to specify tests in:
      #     //
      #     //  "<X>,<Y>A"  add X partial buffers of size Y
      #     //  "<X>a"    add X full buffers at end
      #     //  "<X>,<Y>C"  change entry X to a partial buffer of size Y
      #     //  "<X>c"    change entry at position X to a full buffer
      #     //  "<X>,<Y>I"  insert partial buffer of size Y at position X
      #     //  "<X>i"    insert a full buffer at position X
      #     //  "<X>,<Y>R"  remove Y entries at position X
      #     //  "<X>r"    remove one entry at position X
      #     //
      #     //  ">"     commit changes
      #     //  "<"     rollback changes
      #     //
      #     //  " "     ignore spaces
      #     //  "<X>,"    for additional args
      #     //  "<X>="    verify number of rows is X

      scripts =  [
                  #       //   A  B  C  D    E    F   G    H    I J
                  "5a 5a 5a 1r   5r   10r   6r     2r   > 10=", 
                  "5a 5a 5a 1,200C 5,200C 10,200C 6,200C 2,200C > 15=",
                  "5a 5a 5a 1,300C 5,300C 10,300C 6,300C 2,300C > 15=", 

                   #       //   A   B   C   D     E     F      G     H     I J
                  "50a 50a 50a 10r   50r   100r   60r   20r   > 145=", 
                  "50a 50a 50a 10,200C 50,200C 100,200C 60,200C 20,200C > 150=", 
                  "50a 50a 50a 10,300C 50,300C 100,300C 60,300C 20,300C > 150=", 

#                   #       //   A     B   C     D   E   F  G H I J
                  "50a 50a 50a 10c 50c 100c 60c 20c > 150=", # // asserts in 1.7b1

#                   #       //   A    B   C  D E
                  "3,3a 1,10C 1,1C > 3=", # // asserts in 1.7 - June 6 build

#                   "", 0
                 ]

      scripts.each {|p|
        v1 = s1.view("a");
        v1.remove_all
        s1.commit();

        assert_equal 0, v1.get_size # // start with a clean slate each time

        fill = ?@
        save = 0;
        row = Metakit::Row.new

        while (p.size > 0)
          fill += 1
          # // default is a string of 255 chars (with additional null byte)
          p1.set(row, fill.chr * 255);

          if p =~ /^\d+/
            arg = p.to_i
            _, p = p.split /^\d+/
          else
            arg = 0
          end

          case p[0]
          when ?A
            p1.set(row, fill.chr * arg);
            arg = save;

          when ?a
            arg.times { v1.add(row) }

          when ?C
            p1.set(row, fill.chr * arg);
            arg = save;

          when ?c
            v1[arg] = row;

          when ?I
            p1.set(row, fill.chr * arg);
            arg = save;

          when ?i
            v1.insert_row_at(arg, row);

          when ?R
            v1.remove_at(save, arg);

          when ?r
            v1.remove_at(arg);

          when ?>
            s1.commit();

          when ?<
            s1.rollback();
            v1 = s1.view("a");

#          when ?\x20
#            next 

          when ?,
            save = arg;

          when ?=
            assert_equal arg, v1.get_size
          end
          
          p = p[1..-1]
        end
      }

      s1.commit();
    end
    #   D(r04a);
    R('r04a');
  end
end
