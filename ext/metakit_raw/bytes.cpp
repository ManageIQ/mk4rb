#include "mk4rb.h"

VALUE cBytes;
VALUE cBytesPtr; 

static VALUE bytes_new (VALUE self, VALUE data, VALUE len)
{
    return wrap_bytes (new c4_Bytes (StringValuePtr (data), NUM2INT (len), true)); 
}

static VALUE bytes_default_new (VALUE self)
{
    return wrap_bytes (new c4_Bytes ());
}

static VALUE bytes_equal (VALUE self, VALUE other)
{
    c4_Bytes* l = unwrap<c4_Bytes> (self);
    c4_Bytes* r = unwrap<c4_Bytes> (other);

    return (*l == *r) ? Qtrue : Qfalse;     
}

static VALUE bytes_not_equal (VALUE self, VALUE other)
{
    c4_Bytes* l = unwrap<c4_Bytes> (self);
    c4_Bytes* r = unwrap<c4_Bytes> (other);

    return (*l != *r) ? Qtrue : Qfalse; 
}

static VALUE bytes_size (VALUE self)
{
    c4_Bytes* l = unwrap<c4_Bytes> (self);
    return INT2NUM (l->Size ()); 
}

static VALUE bytes_contents (VALUE self)
{
    c4_Bytes* l = unwrap<c4_Bytes> (self);
    return rb_str_new((const char *)l->Contents (), l->Size ());
}

static VALUE bytes_set_buffer (VALUE self, VALUE s)
{
    c4_Bytes* l = unwrap<c4_Bytes> (self);

    // return cBytesPtr - handle very carefully
    return Data_Wrap_Struct (cBytesPtr, 0, 0, l->SetBuffer (NUM2INT (s))); 

    return Qnil; 
}

static VALUE bytesPtr_set (VALUE self, VALUE key, VALUE val)
{
    char *ptr; 
    Data_Get_Struct (self, char, ptr);

    char value = (char) (NUM2INT (val));
    *(ptr + NUM2INT (key)) = value;

    return INT2NUM (value);     
}

void init_bytes ()
{
    extern VALUE mMetakit; 
    cBytesPtr = rb_define_class_under (mMetakit, "BytesPtr", rb_cObject);
    rb_define_method (cBytesPtr, "[]=", (RUBY_CFUNC) bytesPtr_set, 2);     
    
    rb_define_singleton_method (cBytes, "new",         (RUBY_CFUNC) bytes_new,         2);
    rb_define_singleton_method (cBytes, "default_new", (RUBY_CFUNC) bytes_default_new, 0);
    rb_define_method           (cBytes, "==",          (RUBY_CFUNC) bytes_equal,       1);
    rb_define_method           (cBytes, "!=",          (RUBY_CFUNC) bytes_not_equal,   1);
    rb_define_method           (cBytes, "size",        (RUBY_CFUNC) bytes_size,        0);
    rb_define_method           (cBytes, "contents",    (RUBY_CFUNC) bytes_contents,    0);
    rb_define_method           (cBytes, "set_buffer",  (RUBY_CFUNC) bytes_set_buffer,  1); 
}
