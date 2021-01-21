require 'rubygems'
require 'mk4rb'

storage = Metakit::Storage.new "mk_test.db", 1
maps    = storage.get_as "maps[mid:S,mwidth:I,mheight:I,mpath:S]"

mid     = Metakit::StringProp.new "mid"
mpath   = Metakit::StringProp.new "mpath"
mwidth  = Metakit::IntProp.new    "mwidth"
mheight = Metakit::IntProp.new    "mheight"

row = Metakit::Row.new

mid.set     row, "A"
mwidth.set  row, 10
mheight.set row, 10
mpath.set   row, "/home/MapA.vxf"
maps.add    row

mid.set row, "B"
mwidth.set row, 20
mheight.set row, 20
mpath.set row, "/home/MapB.vxf"
maps.add row

mid.set row, "C"
mwidth.set row, 30
mheight.set row, 30
mpath.set row, "/home/MapC.vxf"
maps.add row

storage.commit

selectrow_start = Metakit::Row.new
selectrow_end   = Metakit::Row.new

mwidth.set selectrow_start, 20
mwidth.set selectrow_end,   30

tableselect = maps.select_range selectrow_start, selectrow_end

tableselect.get_size.times {|idx|
  printf("map %s has width=%d\n",
         mid.get(tableselect.get_at(idx)),
         mwidth.get(tableselect.get_at(idx)))
}


