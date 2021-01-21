#include "mk4rb.h"
#include "mk4io.h"

VALUE cFileStream;

static VALUE filestream_new (VALUE self, VALUE filename, VALUE mode)
{
    FILE *f = fopen (StringValuePtr (filename), StringValuePtr (mode));

    return wrap<c4_FileStream> (cFileStream, new c4_FileStream (f, true)); 
}

static VALUE filestream_close (VALUE self)
{
    c4_FileStream *stream = unwrap<c4_FileStream> (self);
    delete stream;

    // evil: make sure that it won't get called again on garbage collection
    RDATA (self)->dfree = 0;
    return Qnil; 
}

void init_file_stream ()
{
    rb_define_singleton_method (cFileStream, "new",    (RUBY_CFUNC) filestream_new,   2);
    rb_define_method           (cFileStream, "close!", (RUBY_CFUNC) filestream_close, 0); 
}
