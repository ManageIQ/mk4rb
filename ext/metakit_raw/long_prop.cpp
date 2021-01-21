#include "mk4rb.h"

VALUE cLongProp;

static VALUE longProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_long (new c4_LongProp (StringValuePtr (name))); 
}

static VALUE longProp_get (VALUE self, VALUE r)
{
    c4_LongProp *prop = unwrap<c4_LongProp> (self);
    c4_Row     *row  = unwrap<c4_Row>     (r); 

    return LL2NUM ( (*prop) (*row));     
}

static VALUE longProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_LongProp *prop = unwrap<c4_LongProp> (self); 
    c4_Row     *row  = unwrap<c4_Row>     (r);    

    (*prop) (*row) = NUM2LL (val);
    return Qnil;     
}

static VALUE longProp_as_row (VALUE self, VALUE i)
{
    c4_LongProp *prop = unwrap<c4_LongProp> (self); 

    return wrap_row (new c4_Row (prop->AsRow (NUM2INT (i)))); 
}

void init_longprop ()
{
    rb_define_singleton_method (cLongProp, "new", (RUBY_CFUNC) longProp_new, 1);
    rb_define_method           (cLongProp, "get", (RUBY_CFUNC) longProp_get, 1);
    rb_define_method           (cLongProp, "set", (RUBY_CFUNC) longProp_set, 2);
    rb_define_method           (cLongProp, "as_row", (RUBY_CFUNC) longProp_as_row, 1);
}

