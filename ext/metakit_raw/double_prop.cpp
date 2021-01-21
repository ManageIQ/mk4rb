#include "mk4rb.h"

VALUE cDoubleProp;

static VALUE doubleProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_double (new c4_DoubleProp (StringValuePtr (name))); 
}

static VALUE doubleProp_get (VALUE self, VALUE r)
{
    c4_DoubleProp *prop = unwrap<c4_DoubleProp> (self);
    c4_Row     *row  = unwrap<c4_Row>     (r); 

    return rb_float_new ( (*prop) (*row));     
}

static VALUE doubleProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_DoubleProp *prop = unwrap<c4_DoubleProp> (self); 
    c4_Row     *row  = unwrap<c4_Row>     (r);    

    // convert to float
    val = rb_funcall (val, rb_intern ("to_f"), 0);
    
    (*prop) (*row) = RFLOAT (val)->value;
    return Qnil;     
}

static VALUE doubleProp_as_row (VALUE self, VALUE i)
{
    c4_DoubleProp *prop = unwrap<c4_DoubleProp> (self); 

    i = rb_funcall (i, rb_intern ("to_f"), 0); 
    return wrap_row (new c4_Row (prop->AsRow (RFLOAT (i)->value))); 
}

void init_doubleprop ()
{
    rb_define_singleton_method (cDoubleProp, "new", (RUBY_CFUNC) doubleProp_new, 1);
    rb_define_method           (cDoubleProp, "get", (RUBY_CFUNC) doubleProp_get, 1);
    rb_define_method           (cDoubleProp, "set", (RUBY_CFUNC) doubleProp_set, 2);
    rb_define_method           (cDoubleProp, "as_row", (RUBY_CFUNC) doubleProp_as_row, 1);
}

// double_prop.cpp ends here
