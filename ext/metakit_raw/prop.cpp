#include "mk4rb.h"

VALUE cProperty; 

static VALUE property_name (VALUE self)
{
    c4_Property *prop = unwrap<c4_Property> (self);
    
    return rb_str_new2 (prop->Name ()); 
}

static VALUE property_type (VALUE self)
{
    c4_Property *prop = unwrap<c4_Property> (self);

    return INT2NUM (prop->Type ()); 
}

static VALUE property_id (VALUE self)
{
    c4_Property *prop = unwrap<c4_Property> (self);

    return INT2NUM (prop->GetId ());
}

static VALUE property_comma (VALUE self, VALUE prop_ref)
{
    c4_Property *prop  = unwrap<c4_Property> (self);
    c4_Property *prop1 = unwrap<c4_Property> (prop_ref);

    return wrap_view (new c4_View( (*prop,*prop1))); 
}

void init_prop ()
{
    // property methods
    rb_undef_method (rb_singleton_class (cProperty), "new");
    
    rb_define_method (cProperty, "name",         (RUBY_CFUNC) property_name,  0);
    rb_define_method (cProperty, "metakit_type", (RUBY_CFUNC) property_type,  0);
    rb_define_method (cProperty, "metakit_id",   (RUBY_CFUNC) property_id,    0);
    rb_define_method (cProperty, "comma",        (RUBY_CFUNC) property_comma, 1); 
}
