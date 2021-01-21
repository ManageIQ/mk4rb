#include "mk4rb.h"

//     /// Construct a storage using the specified strategy handler
//     c4_Storage(c4_Strategy &, bool = false, int = 1);

//     /// Reconstruct a storage object from a suitable view
//     c4_Storage(const c4_View &);

VALUE cStorage;

static VALUE storage_default_new (VALUE self)
{
    return wrap_storage (new c4_Storage); 
}

static VALUE storage_new (VALUE klass, VALUE db_name, VALUE mode)
{
    Check_Type (db_name, T_STRING);

    char *filename = StringValuePtr (db_name);
    int m = NUM2INT (mode);

    return wrap_storage (new c4_Storage (filename, m)); 
}

static VALUE storage_commit (int argc, VALUE *argv, VALUE self)
{
    VALUE p;
    if (rb_scan_args (argc, argv, "01", &p) == 0)
    {
        p = Qfalse;
    }
    
    c4_Storage *storage = unwrap<c4_Storage> (self);  

    return (storage->Commit (RTEST (p)) ? Qtrue : Qfalse);
}

static VALUE storage_rollback (int argc, VALUE *argv, VALUE self)
{
    VALUE p;
    if (rb_scan_args (argc, argv, "01", &p) == 0)
    {
        p = Qfalse;
    }
    
    c4_Storage *storage = unwrap<c4_Storage> (self);  

    return (storage->Rollback (RTEST (p)) ? Qtrue : Qfalse);
}

static VALUE storage_getas (VALUE self, VALUE desc)
{
    Check_Type (desc, T_STRING);

    c4_Storage *storage = unwrap<c4_Storage> (self);         
    c4_View    view     = storage->GetAs (StringValuePtr (desc));

    return wrap_view (new c4_View (view)); 
}

static VALUE storage_set_structure (VALUE self, VALUE s)
{
    Check_Type (s, T_STRING);

    c4_Storage *storage = unwrap<c4_Storage> (self);
    storage->SetStructure (StringValuePtr (s));

    return Qnil; 
}

static VALUE storage_autocommit (int argc, VALUE *argv, VALUE self)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);

    bool v = true; 
    if (argc > 0)
    {
        v = RTEST (argv[0]);
    }

    return storage->AutoCommit (v) ? Qtrue : Qfalse; 
}

static VALUE storage_description (int argc, VALUE *argv, VALUE self)
{
    char *v = 0;

    if (argc > 1)
        rb_raise(rb_eArgError, "wrong number of arguments (%d for %d)", argc, 1);
    
    if (argc == 1)
    {
        v = StringValuePtr (argv[0]);
    }
        
    c4_Storage *storage = unwrap<c4_Storage> (self);
    const char *r = storage->Description (v); 
    return (r == 0 ? Qnil: rb_str_new2 (r)); 
}

static VALUE storage_view (VALUE self, VALUE name)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);
    return wrap_view (new c4_View (storage->View (StringValuePtr (name)))); 
}

static VALUE storage_view_and_assign (VALUE self, VALUE name, VALUE val)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);

    val = rb_funcall (val, rb_intern ("to_view"), 0);     
    c4_View *view_val = unwrap<c4_View> (val);

    c4_View *result = new c4_View (storage->View(StringValuePtr (name)) = *view_val);
    return wrap_view (result); 
}

static VALUE storage_freespace (VALUE self)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);

    t4_i32 bytes; 
    int size = storage->FreeSpace (&bytes);

    VALUE ary = rb_ary_new ();
    rb_ary_push (ary, INT2NUM (size));
    rb_ary_push (ary, INT2NUM (bytes));

    return ary;         
}

static VALUE storage_close (VALUE self)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);
    delete storage;

    // evil: make sure that it won't get called again on garbage collection
    RDATA (self)->dfree = 0;
    return Qnil; 
}

static VALUE storage_load_from (VALUE self, VALUE stream)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);
    c4_Stream *str = unwrap<c4_Stream> (stream);

    return (storage->LoadFrom (*str) ? Qtrue: Qfalse); 
}

static VALUE storage_save_to (VALUE self, VALUE stream)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);
    c4_Stream *str = unwrap<c4_Stream> (stream);

    storage->SaveTo (*str);
    return Qnil; 
}

static VALUE storage_set_aside (VALUE self, VALUE aside)
{
    c4_Storage *storage       = unwrap<c4_Storage> (self);
    c4_Storage *aside_storage = unwrap<c4_Storage> (aside);

    return (storage->SetAside (*aside_storage) ? Qtrue : Qfalse); 
}

static VALUE storage_get_aside (VALUE self)
{
    c4_Storage *storage       = unwrap<c4_Storage> (self);

    c4_Storage *aside = storage->GetAside ();

    // can we simply wrap it or we can't use destructor on it???
    // wrap_storage (aside)
    return Data_Wrap_Struct (cStorage, 0, 0, aside); 
}

static VALUE storage_strategy (VALUE self)
{
    c4_Storage *storage = unwrap<c4_Storage> (self);
    c4_Strategy& strat  = storage->Strategy ();

    return  Data_Wrap_Struct (cStrategy, 0, 0, &strat);
}

void init_storage ()
{
    // storage methods
    rb_define_singleton_method (cStorage, "default_new",     (RUBY_CFUNC) storage_default_new,     0); 
    rb_define_singleton_method (cStorage, "new",             (RUBY_CFUNC) storage_new,             2);
    
    rb_define_method           (cStorage, "get_as",          (RUBY_CFUNC) storage_getas,           1);
    rb_define_method           (cStorage, "view",            (RUBY_CFUNC) storage_view,            1);
    rb_define_method           (cStorage, "commit",          (RUBY_CFUNC) storage_commit,          -1);
    rb_define_method           (cStorage, "rollback",        (RUBY_CFUNC) storage_rollback,        -1);
    rb_define_method           (cStorage, "set_structure",   (RUBY_CFUNC) storage_set_structure,   1);
    rb_define_method           (cStorage, "autocommit",      (RUBY_CFUNC) storage_autocommit,      -1);
    rb_define_method           (cStorage, "description",     (RUBY_CFUNC) storage_description,     -1);
    rb_define_method           (cStorage, "freespace",       (RUBY_CFUNC) storage_freespace,       0);
    rb_define_method           (cStorage, "close!",          (RUBY_CFUNC) storage_close,           0);
    
    rb_define_method           (cStorage, "load_from",       (RUBY_CFUNC) storage_load_from,       1);
    rb_define_method           (cStorage, "save_to",         (RUBY_CFUNC) storage_save_to,         1);
    
    rb_define_method           (cStorage, "set_aside",       (RUBY_CFUNC) storage_set_aside,       1);     
    rb_define_method           (cStorage, "get_aside",       (RUBY_CFUNC) storage_get_aside,       0);
    
    rb_define_method           (cStorage, "strategy",        (RUBY_CFUNC) storage_strategy,        0);
    rb_define_method           (cStorage, "view_and_assign", (RUBY_CFUNC) storage_view_and_assign, 2); 
}

// storage.cpp ends here
