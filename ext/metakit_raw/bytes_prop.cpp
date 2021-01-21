#include "mk4rb.h"

VALUE cBytesProp;

static VALUE bytesProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_bytesprop (new c4_BytesProp (StringValuePtr (name))); 
}

static VALUE bytesProp_get (VALUE self, VALUE r)
{
    c4_BytesProp *prop = unwrap<c4_BytesProp> (self);
    c4_Row       *row  = unwrap<c4_Row>     (r); 

    return wrap_bytes (new c4_Bytes (prop->Get (*row))); 
}

static VALUE bytesProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_BytesProp *prop = unwrap<c4_BytesProp> (self); 
    c4_Row       *row  = unwrap<c4_Row>     (r);
    c4_Bytes     *bytes= unwrap<c4_Bytes> (val); 


    prop->Set (*row, *bytes); 
    return Qnil;     
}

static VALUE bytesProp_as_row (VALUE self, VALUE i)
{
    c4_BytesProp *prop = unwrap<c4_BytesProp> (self);
    c4_Bytes     *bytes= unwrap<c4_Bytes> (i); 

    return wrap_row (new c4_Row (prop->AsRow (*bytes))); 
}

static VALUE bytesProp_ref (VALUE self, VALUE r)
{
    c4_BytesProp *prop = unwrap<c4_BytesProp> (self);
    c4_Row       *row  = unwrap<c4_Row>     (r);

    return wrap_bytesref (new c4_BytesRef ((*prop)(*row)));
}    

void init_bytesprop ()
{
    rb_define_singleton_method (cBytesProp, "new", (RUBY_CFUNC) bytesProp_new, 1);
    rb_define_method           (cBytesProp, "get", (RUBY_CFUNC) bytesProp_get, 1);
    rb_define_method           (cBytesProp, "set", (RUBY_CFUNC) bytesProp_set, 2);
    rb_define_method           (cBytesProp, "ref", (RUBY_CFUNC) bytesProp_ref, 1); 
    rb_define_method           (cBytesProp, "as_row", (RUBY_CFUNC) bytesProp_as_row, 1);
}
