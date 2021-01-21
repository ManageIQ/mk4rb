#include "mk4rb.h"

VALUE cStringProp;

static VALUE stringProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_str (new c4_StringProp (StringValuePtr (name))); 
}

static VALUE stringProp_get (VALUE self, VALUE r)
{
    c4_StringProp *prop = unwrap<c4_StringProp> (self);
    c4_Row        *row  = unwrap<c4_Row>        (r); 

    return rb_str_new2 ( (*prop) (*row));     
}

static VALUE stringProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_StringProp *prop = unwrap<c4_StringProp> (self); 
    c4_Row        *row  = unwrap<c4_Row>        (r);    
    
    (*prop) (*row) = StringValuePtr (val);
    return Qnil;     
}

static VALUE stringProp_as_row (VALUE self, VALUE s)
{
    c4_StringProp *prop = unwrap<c4_StringProp> (self); 

    return wrap_row (new c4_Row (prop->AsRow (StringValuePtr (s)))); 
}

void init_strprop ()
{
    // stringprop methods
    rb_define_singleton_method (cStringProp, "new",    (RUBY_CFUNC) stringProp_new,    1);
    rb_define_method           (cStringProp, "get",    (RUBY_CFUNC) stringProp_get,    1);
    rb_define_method           (cStringProp, "set",    (RUBY_CFUNC) stringProp_set,    2);
    rb_define_method           (cStringProp, "as_row", (RUBY_CFUNC) stringProp_as_row, 1);
}

// string_prop.cpp ends here
