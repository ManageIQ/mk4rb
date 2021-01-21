#include "mk4rb.h"

VALUE cViewProp;

static VALUE viewProp_new (VALUE klass, VALUE name)
{
    Check_Type (name, T_STRING);

    return wrap_viewprop (new c4_ViewProp (StringValuePtr (name))); 
}

static VALUE viewProp_get (VALUE self, VALUE r)
{
    c4_ViewProp *prop = unwrap<c4_ViewProp> (self);
    c4_Row      *row  = unwrap<c4_Row>      (r); 

    return wrap_view (new c4_View (prop->Get(*row)));     
}

static VALUE viewProp_set (VALUE self, VALUE r, VALUE val)
{
    c4_ViewProp *prop = unwrap<c4_ViewProp> (self); 
    c4_Row      *row  = unwrap<c4_Row>     (r);
    c4_View     *view = unwrap<c4_View> (val); 

    prop->Set (*row, *view); 
    return Qnil;     
}

static VALUE viewProp_as_row (VALUE self, VALUE i)
{
    c4_ViewProp *prop = unwrap<c4_ViewProp> (self);
    c4_View *view = unwrap<c4_View> (i); 

    return wrap_row (new c4_Row (prop->AsRow (*view))); 
}

void init_viewprop ()
{
    // intprop methods
    rb_define_singleton_method (cViewProp, "new", (RUBY_CFUNC) viewProp_new, 1);
    rb_define_method           (cViewProp, "get", (RUBY_CFUNC) viewProp_get, 1);
    rb_define_method           (cViewProp, "set", (RUBY_CFUNC) viewProp_set, 2);
    rb_define_method           (cViewProp, "as_row", (RUBY_CFUNC) viewProp_as_row, 1);
}

// view_prop.cpp ends here

