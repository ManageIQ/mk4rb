#include "mk4rb.h"

VALUE cCursor;

static VALUE cursor_star (VALUE self)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);

    return wrap_rowref (new c4_RowRef (**c)); 
}

static VALUE cursor_star_at (VALUE self, VALUE idx)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);

    return wrap_rowref (new c4_RowRef ((*c)[NUM2INT (idx)])); 
}

static VALUE cursor_plus (VALUE self, VALUE intValue)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);

    return wrap_cursor (new c4_Cursor (*c + NUM2INT (intValue))); 
}

static VALUE cursor_minus (VALUE self, VALUE intValue)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);

    return wrap_cursor (new c4_Cursor (*c - NUM2INT (intValue))); 
}

static VALUE cursor_distance (VALUE self, VALUE cur)
{
    c4_Cursor *c  = unwrap<c4_Cursor> (self);
    c4_Cursor *c1 = unwrap<c4_Cursor> (cur);

    return INT2NUM (*c - *c1); 
}

static VALUE cursor_equal (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c == *o) ? Qtrue: Qfalse;
}

static VALUE cursor_not_equal (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c != *o) ? Qtrue: Qfalse;
}

static VALUE cursor_less (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c < *o) ? Qtrue: Qfalse;
}

static VALUE cursor_greater (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c > *o) ? Qtrue: Qfalse;
}

static VALUE cursor_less_equal (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c <= *o) ? Qtrue: Qfalse;
}

static VALUE cursor_greater_equal (VALUE self, VALUE other)
{
    c4_Cursor *c = unwrap<c4_Cursor> (self);
    c4_Cursor *o = unwrap<c4_Cursor> (other);

    return (*c >= *o) ? Qtrue: Qfalse;
}

void init_cursor ()
{
    rb_define_method (cCursor, "to_rowref", (RUBY_CFUNC) cursor_star,     0);
    rb_define_method (cCursor, "[]",        (RUBY_CFUNC) cursor_star_at,  1);
    rb_define_method (cCursor, "+",         (RUBY_CFUNC) cursor_plus,     1);
    rb_define_method (cCursor, "-",         (RUBY_CFUNC) cursor_minus,    1);
    rb_define_method (cCursor, "distance",  (RUBY_CFUNC) cursor_distance, 0);

    rb_define_method (cCursor, "==", (RUBY_CFUNC) cursor_equal,         1);
    rb_define_method (cCursor, "!=", (RUBY_CFUNC) cursor_not_equal,     1);
    rb_define_method (cCursor, "<",  (RUBY_CFUNC) cursor_less,          1);
    rb_define_method (cCursor, ">",  (RUBY_CFUNC) cursor_greater,       1);
    rb_define_method (cCursor, "<=", (RUBY_CFUNC) cursor_less_equal,    1);
    rb_define_method (cCursor, ">=", (RUBY_CFUNC) cursor_greater_equal, 1);
}
