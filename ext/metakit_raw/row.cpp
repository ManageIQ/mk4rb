#include "mk4rb.h"

VALUE cRow;

static VALUE row_new (VALUE klass)
{
    return wrap_row (new c4_Row);
}

static VALUE row_plus (VALUE self, VALUE other_row)
{
    c4_Row *r1 = unwrap<c4_Row> (self);
    c4_Row *r2 = unwrap<c4_Row> (other_row);

    return wrap_row (new c4_Row ((*r1) + (*r2))); 
}

static VALUE row_concat (VALUE self, VALUE other_row)
{
    c4_Row *r1 = unwrap<c4_Row> (self);
    c4_Row *r2 = unwrap<c4_Row> (other_row);

    r1->ConcatRow (*r2);
    return Qnil; 
}

void init_row ()
{
    rb_define_singleton_method (cRow, "new",    (RUBY_CFUNC) row_new,    0);
    rb_define_method           (cRow, "+",      (RUBY_CFUNC) row_plus,   1);
    rb_define_method           (cRow, "concat", (RUBY_CFUNC) row_concat, 1); 
}


