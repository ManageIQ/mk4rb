#include "mk4rb.h"

VALUE cFloatProp;

static VALUE floatProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_float (new c4_FloatProp (StringValuePtr (name))); 
}

static VALUE floatProp_get (VALUE self, VALUE r)
{
    c4_FloatProp *prop = unwrap<c4_FloatProp> (self);
    c4_Row     *row  = unwrap<c4_Row>     (r); 

    return rb_float_new ( (*prop) (*row));     
}

static VALUE floatProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_FloatProp *prop = unwrap<c4_FloatProp> (self); 
    c4_Row     *row  = unwrap<c4_Row>     (r);    

    val = rb_funcall (val, rb_intern ("to_f"), 0); 
    (*prop) (*row) = RFLOAT (val)->value;
    return Qnil;     
}

static VALUE floatProp_as_row (VALUE self, VALUE i)
{
    c4_FloatProp *prop = unwrap<c4_FloatProp> (self); 

    i = rb_funcall (i, rb_intern ("to_f"), 0); 
    return wrap_row (new c4_Row (prop->AsRow (RFLOAT (i)->value))); 
}

void init_floatprop ()
{
    // floatprop methods
    rb_define_singleton_method (cFloatProp, "new", (RUBY_CFUNC) floatProp_new, 1);
    rb_define_method           (cFloatProp, "get", (RUBY_CFUNC) floatProp_get, 1);
    rb_define_method           (cFloatProp, "set", (RUBY_CFUNC) floatProp_set, 2);
    rb_define_method           (cFloatProp, "as_row", (RUBY_CFUNC) floatProp_as_row, 1);
}

// float_prop.cpp ends here
