#include "mk4rb.h"

VALUE cBytesRef;

static VALUE bytesRef_access (int argc, VALUE *argv, VALUE self)
{
    c4_BytesRef *ref = unwrap<c4_BytesRef> (self);

    VALUE i, j, k;
    rb_scan_args (argc, argv, "12", &i, &j, &k);
    if (NIL_P (j))
    {
        j = INT2NUM (0);
    }
    if (NIL_P (k))
    {
        k = Qfalse;
    }

    return wrap_bytes (new c4_Bytes (ref->Access (NUM2INT (i), NUM2INT (j), RTEST (k)))); 
}

static VALUE bytesRef_modify (int argc, VALUE *argv, VALUE self)
{
    c4_BytesRef *ref = unwrap<c4_BytesRef> (self);

    VALUE i, j, k;
    rb_scan_args (argc, argv, "21", &i, &j, &k);
    if (NIL_P (k))
    {
        k = INT2NUM (0);
    }

    c4_Bytes *bytes = unwrap<c4_Bytes> (i);
    return (ref->Modify (*bytes, NUM2INT (j), NUM2INT (k)) ? Qtrue : Qfalse); 
}

void init_bytesref ()
{
    rb_define_method (cBytesRef, "access", (RUBY_CFUNC) bytesRef_access, -1);
    rb_define_method (cBytesRef, "modify", (RUBY_CFUNC) bytesRef_modify, -1);     
}
