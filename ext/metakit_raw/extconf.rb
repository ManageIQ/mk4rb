require 'mkmf'

if RUBY_PLATFORM =~ /mswin/
  $INCFLAGS << " -Iwin32 "
  $CFLAGS.sub! /-MD/, "-MT"
  if have_header("mk4.h") && have_library("win32/mk4vc70s")
     create_makefile("metakit_raw") 
  else
     puts "Can't build an extension, either you don't have a c++ compiler or metakit installed"
  end
else
  if have_header("mk4.h") && have_library("stdc++") && have_library("mk4")
     create_makefile("metakit_raw") 
  else
     puts "Can't build an extension, either you don't have a c++ compiler or metakit installed"
  end
end  



