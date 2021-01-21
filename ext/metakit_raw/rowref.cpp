#include "mk4rb.h"

VALUE cRowRef;

static VALUE rowref_equal (VALUE self, VALUE other)
{
    c4_RowRef *r1 = unwrap<c4_RowRef> (self);
    c4_RowRef *r2 = unwrap<c4_RowRef> (other);

    return (*r1 == *r2) ? Qtrue : Qfalse; 
}

static VALUE rowref_assign (VALUE self, VALUE other)
{
    c4_RowRef *r1 = unwrap<c4_RowRef> (self); 
    c4_RowRef *r2 = unwrap<c4_RowRef> (other);

    return wrap_rowref (new c4_RowRef (*r1 = *r2));     
}

static VALUE rowref_cursor (VALUE self)
{
    c4_RowRef *r = unwrap<c4_RowRef> (self);
    return wrap_cursor (new c4_Cursor (&(*r))); 
}

static VALUE rowref_container (VALUE self)
{
    c4_RowRef *r = unwrap<c4_RowRef> (self);
    return wrap_view (new c4_View (r->Container ())); 
}

void init_rowref ()
{
    rb_define_method (cRowRef, "==", (RUBY_CFUNC) rowref_equal, 1);
    rb_define_method (cRowRef, "assign", (RUBY_CFUNC) rowref_assign, 1);
    rb_define_method (cRowRef, "cursor", (RUBY_CFUNC) rowref_cursor, 0);
    rb_define_method (cRowRef, "container", (RUBY_CFUNC) rowref_container, 0); 
}
