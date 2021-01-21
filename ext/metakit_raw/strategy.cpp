#include "mk4rb.h"

VALUE cStrategy;

static VALUE strategy_data_read (VALUE self, VALUE pos, VALUE len)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    char *ptr = new char[NUM2INT (len)]; 
    int num_read = s->DataRead (NUM2INT (pos), ptr, NUM2INT (len));

    VALUE str = rb_str_new (ptr, num_read);
    delete ptr;
    
    return str; 
}

static VALUE strategy_data_write (VALUE self, VALUE pos, VALUE data)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    s->DataWrite (NUM2INT (pos), StringValuePtr (data), RSTRING (data)->len);
    return Qnil; 
}

static VALUE strategy_filesize (VALUE self)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    return INT2NUM (s->FileSize ()); 
}

static VALUE strategy_fresh_generation (VALUE self)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    return INT2NUM (s->FreshGeneration ()); 
}

static VALUE strategy_reset_file_mapping (VALUE self)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    s->ResetFileMapping (); 
    return Qnil; 
}

static VALUE strategy_data_commit (VALUE self, VALUE v)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    s->DataCommit (NUM2INT (v)); 
    return Qnil; 
}

static VALUE strategy_is_valid (VALUE self)
{
    c4_Strategy *s = unwrap<c4_Strategy> (self);

    return (s->IsValid () ? Qtrue : Qfalse); 
}

void init_strategy ()
{
    rb_define_method (cStrategy, "file_size", (RUBY_CFUNC)strategy_filesize, 0);
    rb_define_method (cStrategy, "is_valid", (RUBY_CFUNC)strategy_is_valid, 0);
    rb_define_method (cStrategy, "data_commit", (RUBY_CFUNC)strategy_data_commit, 1);
    rb_define_method (cStrategy, "fresh_generation", (RUBY_CFUNC)strategy_fresh_generation, 0);
    rb_define_method (cStrategy, "reset_file_mapping", (RUBY_CFUNC) strategy_reset_file_mapping, 0);

    rb_define_method (cStrategy, "data_read", (RUBY_CFUNC)strategy_data_read, 2);
    rb_define_method (cStrategy, "data_write", (RUBY_CFUNC) strategy_data_write, 2); 
}
