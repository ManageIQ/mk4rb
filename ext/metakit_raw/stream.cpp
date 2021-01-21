#include "mk4rb.h"

VALUE cStream;

static VALUE stream_read (VALUE self, VALUE len)
{
    c4_Stream *stream = unwrap<c4_Stream> (self);

    char *ptr = new char[NUM2INT (len)]; 
    int num_read = stream->Read (ptr, NUM2INT (len));

    VALUE str = rb_str_new (ptr, num_read);
    delete ptr;
    
    return str; 
}

static VALUE stream_write (VALUE self, VALUE data)
{
    c4_Stream *stream = unwrap<c4_Stream> (self);

    return (stream->Write (StringValuePtr (data), RSTRING (data)->len) ? Qtrue : Qfalse); 
}

void init_stream ()
{
    rb_define_method (cStream, "read", (RUBY_CFUNC) stream_read, 1);
    rb_define_method (cStream, "write", (RUBY_CFUNC) stream_write, 1); 
}
