# adapted from dump.cpp
#  Datafile dump utility sample code
require 'rubygems'
require 'mk4rb'

#
# Recursively display the entire view contents. The results shown do not
# depend on file layout (free space, file positions, flat vs. on-demand).

def view_display v, l = 0

  types = ""
  hasData = false
  hasSubs = false

  # display header info and collect all data types
  printf("%*s VIEW %5d rows =", l, "", v.get_size)
  v.num_properties.times {|n|
    prop = v.nth_property n
    t = prop.metakit_type;

    printf(" %s:%c", prop.name, t);
    
    types << t
    
    if (t == ?V)
      hasSubs = true;
    else
      hasData = true;
    end
  }
  puts

  v.get_size.times {|j|
    if (hasData)  #// data properties are all shown on the same line
      printf("%*s %4d:", l, "", j);
      r = v[j];

      types.size.times {|k|
        p = v.nth_property k

        case types[k]
        when ?I
          printf(" %d", p.get(r))

        when ?F
          printf(" %g", p.get(r))

        when ?D
          printf(" %.12g", p.get(r))

        when ?S
          printf(" '%s'", p.get(r));

        when ?M, ?B
          data = p.get(r)
          printf(" (%db)", data.size());

        else
          if (types[k] != ?V)
            printf(" (%c?)", types[k]);
          end
        end
      }

      printf("\n");
    end

    if (hasSubs)  # subviews are then shown, each as a separate block
      types.size.times {|k|
        if (types[k] == ?V)
          prop = v.nth_property(k);
          printf("%*s %4d: subview '%s'\n", l, "", j, prop.name)
          view_display(prop.get(v[j]), l + 2)
        end
      }
    end
  }
end

def main filename
  Metakit::Storage.open(filename, 0) {|store|
    printf("%s: %d properties\n  %s\n\n",
           filename, store.num_properties,
           store.description);
    view_display store
  }
end

if __FILE__ == $0 && ARGV.size > 0
  main ARGV[0]
end
