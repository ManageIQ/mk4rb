# adapted from demo.cpp
# //  An example using the Metakit C++ persistence library

# /////////////////////////////////////////////////////////////////////////////
# //
# //  This code demonstrates:
# //
# //    - Creating a persistent view and adding two data rows to it.
# //    - Adding a third data row using Metakit's operator shorthands.
# //    - Adding an additional property without losing the existing data.
# //    - Storing an additional view in the data file later on.
# //    - Inserting a new record into one of the views in the datafile.
# //    - Real persistence, the data file will grow each time this is run.
# //
# /////////////////////////////////////////////////////////////////////////////

require 'rubygems'
require 'mk4rb'

def main
  # These properties could just as well have been declared globally.
  pName, pCountry = Metakit::StringProp[:name, :country]

  #  Note: be careful with the lifetime of views vs. storage objects.
  # When a storage object goes away, all associated views are cleared.
  Metakit::Storage.open("myfile.dat", 1) {|storage|

    # There are two ways to make views persistent, but the c4_View::Store call
    # call used in previous demos will be dropped, use "c4_View::GetAs" instead.
  
    # Start with an empty view of the proper structure.
    vAddress = storage.get_as "address[name:S,country:S]"

    # Let's add two rows of data to the view.
    row = Metakit::Row.new

    pName.set row, "John Williams"
    pCountry.set row, "UK"
    vAddress.add row

    pName.set row, "Paco Pena"
    pCountry.set row, "Spain"
    vAddress.add(row);

    # A simple check to prove that the data is in the view.
    printf "The country of %s is: %s\n", pName.get(vAddress[1]), pCountry.get(vAddress[1])

    # This saves the data to file.
    storage.commit(); # Data file now contains 2 addresses.

    # A very compact notation to create and add a third row.
    vAddress.add(pName["Julien Coco"] + pCountry["Netherlands"])

    storage.commit(); # Data file now contains 3 addresses.

    # Add a third property to the address view ("on-the-fly").
    vAddress = storage.get_as "address[name:S,country:S,age:I]"

    # Set the new age property in one of the existing addresses.
    pAge = Metakit::IntProp.new "age"
    pAge.set vAddress[1], 44

    storage.commit() 

    # Add a second view to the data file, leaving the first view intact.
    vInfo = storage.get_as "info[version:I]"

    # Add some data, a single integer in this case.
    pVersion = Metakit::IntProp.new "version"
    vInfo.add pVersion[100]

    storage.commit(); # Data file now contains 3 addresses and 1 info rec.

    # Insert a row into the address view.  Note that another (duplicate)
    # property definition is used here - just to show it can be done.
    pYears = Metakit::IntProp.new("age");  # On file this is still the "age" field.

    vAddress.insert_row_at(2, pName["Julian Bream"] + pYears [50])

    # Preceding commits were only included for demonstration purposes.
    storage.commit(); # Datafile now contains 4 addresses and 1 info rec.

    # To inspect the data file, use the dump utility: "DUMP MYFILE.DAT".
    # It should generate the following output:
    #
    #    myfile.dat: 3 properties
    #      address[name:S,country:S,age:I],info[version:I]
    #
    #     VIEW   1 rows = address:V info:V
    #      0: subview 'address'
    #       VIEW   4 rows = name:S country:S age:I
    #        0: 'John Williams' 'UK' 0
    #        1: 'Paco Pena' 'Spain' 44
    #        2: 'Julian Bream' '' 50
    #        3: 'Julien Coco' 'Netherlands' 0
    #      0: subview 'info'
    #       VIEW   1 rows = version:I
    #        0: 100
    #
    # Note: results will differ if this program is run more than once.
  }
end

main if __FILE__ == $0
  
