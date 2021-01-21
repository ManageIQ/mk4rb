#include "mk4rb.h"

VALUE cIntProp;

static VALUE intProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_int (new c4_IntProp (StringValuePtr (name))); 
}

static VALUE intProp_get (VALUE self, VALUE r)
{
    c4_IntProp *prop = unwrap<c4_IntProp> (self);
    c4_Row     *row  = unwrap<c4_Row>     (r); 

    return INT2NUM ( (*prop) (*row));     
}

static VALUE intProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_IntProp *prop = unwrap<c4_IntProp> (self); 
    c4_Row     *row  = unwrap<c4_Row>     (r);    

    (*prop) (*row) = NUM2INT (val);
    return Qnil;     
}

static VALUE intProp_as_row (VALUE self, VALUE i)
{
    c4_IntProp *prop = unwrap<c4_IntProp> (self); 

    return wrap_row (new c4_Row (prop->AsRow (NUM2INT (i)))); 
}

void init_intprop ()
{
    // intprop methods
    rb_define_singleton_method (cIntProp, "new", (RUBY_CFUNC) intProp_new, 1);
    rb_define_method           (cIntProp, "get", (RUBY_CFUNC) intProp_get, 1);
    rb_define_method           (cIntProp, "set", (RUBY_CFUNC) intProp_set, 2);
    rb_define_method           (cIntProp, "as_row", (RUBY_CFUNC) intProp_as_row, 1);
}


// int_prop.cpp ends here
