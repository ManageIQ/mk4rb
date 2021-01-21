require 'mkmf'

if RUBY_PLATFORM =~ /mswin/
  $INCFLAGS << " -Iwin32 "
  have_header("mk4.h")
  have_library("win32/mk4vc70s")
else
  have_header "mk4.h"
  have_library "stdc++"
  have_library "mk4"
end
  
create_makefile("metakit_raw")

