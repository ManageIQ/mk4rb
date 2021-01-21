#include "mk4rb.h"

VALUE cView;

static VALUE view_nth_property (VALUE self, VALUE idx)
{
    c4_View *view = unwrap<c4_View> (self);

    const c4_Property& prop = view->NthProperty (NUM2INT (idx));
    switch (prop.Type ())
    {
    case 'I':
        // int
        return wrap_unsafe<c4_IntProp> (cIntProp, & ( (c4_IntProp&)prop)); 
    case 'L':
        // long
        return wrap_unsafe<c4_LongProp> (cLongProp, & ( (c4_LongProp&)prop)); 
    case 'F':
        // float
        return wrap_unsafe<c4_FloatProp> (cFloatProp, & ( (c4_FloatProp&)prop)); 
    case 'D':
        // double
        return wrap_unsafe<c4_DoubleProp> (cDoubleProp, & ( (c4_DoubleProp&)prop)); 
    case 'S':
        // string
        return wrap_unsafe<c4_StringProp> (cStringProp, & ( (c4_StringProp&)prop)); 
    case 'B':
        // memo
        return wrap_unsafe<c4_BytesProp> (cBytesProp, & ( (c4_BytesProp&)prop)); 
    case 'V':
        // view
        return wrap_unsafe<c4_ViewProp> (cViewProp, & ( (c4_ViewProp&)prop)); 
    default:        
        return wrap_unsafe<c4_Property> (cProperty, &prop);
    }
}

static VALUE view_find_property (VALUE self, VALUE idx)
{
    c4_View *view = unwrap<c4_View> (self);
    return INT2NUM (view->FindProperty (NUM2INT (idx)));
}

static VALUE view_find_prop_index_by_name (VALUE self, VALUE name)
{
    c4_View *view = unwrap<c4_View> (self);
    return INT2NUM (view->FindPropIndexByName (StringValuePtr (name)));
}

static VALUE view_duplicate (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Duplicate ()));
}

static VALUE view_clone (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Clone ()));
}

static VALUE view_add_property (VALUE self, VALUE prop)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_Property* pr = unwrap<c4_Property> (prop);
    
    return INT2NUM (view->AddProperty (*pr));
}

static VALUE view_comma (VALUE self, VALUE prop)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_Property* pr = unwrap<c4_Property> (prop);
    
    return wrap_view (new c4_View ( ((*view),(*pr))));
}

static VALUE view_new (VALUE self)
{
    return wrap_view (new c4_View);
}

static VALUE view_add (VALUE self, VALUE r)
{
    c4_View *view = unwrap<c4_View> (self); 
    c4_Row  *row  = unwrap<c4_Row>  (r); 

    return INT2NUM (view->Add (*row)); 
}

static VALUE view_select (VALUE self, VALUE row)
{
    c4_View *view = unwrap<c4_View> (self); 
    c4_Row  *row1 = unwrap<c4_Row>  (row);

    return wrap_view (new c4_View (view->Select (*row1)));
}
    
static VALUE view_select_range (VALUE self, VALUE r1, VALUE r2)
{
    c4_View *view = unwrap<c4_View> (self); 
    
    c4_Row  *row1 = unwrap<c4_Row>  (r1);   
    c4_Row  *row2 = unwrap<c4_Row>  (r2);   

    return wrap_view (new c4_View (view->SelectRange (*row1, *row2))); 
}

static VALUE view_get_size (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self); 

    return INT2NUM (view->GetSize ());
}

static VALUE view_get_at (VALUE self, VALUE idx)
{
    c4_View *view = unwrap<c4_View> (self); 

    return wrap_rowref (new c4_RowRef (view->GetAt (NUM2INT (idx)))); 
}

static VALUE view_set_at (VALUE self, VALUE idx, VALUE row)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_Row  *r    = unwrap<c4_Row> (row); 

    view->SetAt (NUM2INT (idx), *r);
    return Qnil; 
}

static VALUE view_insert_view_at (VALUE self, VALUE i, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);
    view->InsertAt (NUM2INT (i), * (unwrap<c4_View> (v)));
    return Qnil;
}
                    
static VALUE view_insert_row_at (int argc, VALUE *argv, VALUE self)
{
    VALUE index, row, n; 
    
    if (rb_scan_args (argc, argv, "21", &index, &row, &n) == 2)
    {
        n = INT2NUM (1);
    }

    c4_View *view = unwrap<c4_View> (self);
    view->InsertAt (NUM2INT (index), * (unwrap<c4_Row> (row)), NUM2INT (n));

    return Qnil; 
}

static VALUE view_remove_at (int argc, VALUE *argv, VALUE self)
{
    VALUE index, n;

    if (rb_scan_args (argc, argv, "11", &index, &n) == 1)
    {
        n = INT2NUM (1);
    }

    c4_View *view = unwrap<c4_View> (self);
    view->RemoveAt (NUM2INT (index), NUM2INT (n));

    return Qnil;     
}

static VALUE view_set_size (int argc, VALUE *argv, VALUE self)
{
    VALUE i, j;
    if (rb_scan_args (argc, argv, "11", &i, &j) == 1)
    {
        j = INT2NUM (-1);
    }

    c4_View *view = unwrap<c4_View> (self);
    view->SetSize (NUM2INT (i), NUM2INT (j));
    return Qnil; 
}

static VALUE view_remove_all (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    view->RemoveAll (); 
    return Qnil; 
}

static VALUE view_num_properties (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return INT2NUM (view->NumProperties ()); 
}

static VALUE view_description (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return rb_str_new2 (view->Description ());
}

static VALUE view_sort (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Sort ()));
}

static VALUE view_sort_on (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->SortOn (*v1)));
}

static VALUE view_sort_on_reverse (VALUE self, VALUE v, VALUE vv)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *v1   = unwrap<c4_View> (v);
    c4_View *v2   = unwrap<c4_View> (vv);
    
    return wrap_view (new c4_View (view->SortOnReverse (*v1, *v2)));
}

static VALUE view_project (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Project (*v1)));
}

static VALUE view_project_without (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->ProjectWithout (*v1)));
}

static VALUE view_slice (int argc, VALUE *argv, VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);

    VALUE i, j, k;
    rb_scan_args (argc, argv, "12", &i, &j, &k);
    if (NIL_P (j))
    {
        j = INT2NUM (-1);
    }

    if (NIL_P (k))
    {
        k = INT2NUM (1);
    }

    return wrap_view (new c4_View (view->Slice (NUM2INT (i), NUM2INT (j), NUM2INT (k))));
}

static VALUE view_product (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Product (*v1)));
}

static VALUE view_remap_with (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->RemapWith (*v1)));
}

static VALUE view_pair (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Pair (*v1)));
}

static VALUE view_concat (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Concat (*v1)));
}

static VALUE view_rename (VALUE self, VALUE p1, VALUE p2)
{
    c4_View     *view  = unwrap<c4_View>     (self);
    c4_Property *pp1   = unwrap<c4_Property> (p1);
    c4_Property *pp2   = unwrap<c4_Property> (p2); 
    
    return wrap_view (new c4_View (view->Rename (*pp1, *pp2)));
}

static VALUE view_group_by (VALUE self, VALUE v, VALUE vp)
{
    c4_View *view    = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1      = unwrap<c4_View> (v);
    
    c4_ViewProp *vp1 = unwrap<c4_ViewProp> (vp); 
    
    return wrap_view (new c4_View (view->GroupBy (*v1, *vp1)));
}

static VALUE view_counts (VALUE self, VALUE v, VALUE ip)
{
    c4_View *view    = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1      = unwrap<c4_View> (v);
    
    c4_IntProp *ip1 = unwrap<c4_IntProp> (ip); 
    
    return wrap_view (new c4_View (view->Counts (*v1, *ip1)));
}

static VALUE view_unique (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Unique ()));
}

static VALUE view_union (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Union (*v1)));
}

static VALUE view_intersect (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Intersect (*v1)));
}

static VALUE view_different (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Different (*v1)));
}

static VALUE view_minus (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);

    v = rb_funcall (v, rb_intern ("to_view"), 0); 
    c4_View *v1   = unwrap<c4_View> (v);
    
    return wrap_view (new c4_View (view->Minus (*v1)));
}

static VALUE view_join_prop (int argc, VALUE *argv, VALUE self)
{
    VALUE v, b;
    rb_scan_args (argc, argv, "11", &v, &b);
    if (NIL_P (b))
    {
        b = Qfalse;
    }

    c4_View     *view = unwrap<c4_View>     (self);
    c4_ViewProp *prop = unwrap<c4_ViewProp> (v);
    
    return wrap_view (new c4_View (view->JoinProp (*prop, RTEST (b)))); 
}

static VALUE view_join (int argc, VALUE *argv, VALUE self)
{
    VALUE v1, v2, b;
    rb_scan_args (argc, argv, "21", &v1, &v2, &b);
    if (NIL_P (b))
    {
        b = Qfalse;
    }

    v1 = rb_funcall (v1, rb_intern ("to_view"), 0);
    v2 = rb_funcall (v2, rb_intern ("to_view"), 0); 

    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Join (*(unwrap<c4_View> (v1)), *(unwrap<c4_View> (v2)), RTEST (b)))); 
}

static VALUE view_read_only (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->ReadOnly ()));
}

static VALUE view_blocked (VALUE self)
{
    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Blocked ()));
}

static VALUE view_hash (int argc, VALUE *argv, VALUE self)
{
    VALUE v1, i;
    rb_scan_args (argc, argv, "11", &v1, &i);
    if (NIL_P (i))
    {
        i = INT2NUM (1);
    }

    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Hash (*(unwrap<c4_View> (v1)), NUM2INT (i)))); 
}

static VALUE view_ordered (int argc, VALUE *argv, VALUE self)
{
    VALUE i;
    rb_scan_args (argc, argv, "01", &i);
    if (NIL_P (i))
    {
        i = INT2NUM (1);
    }

    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Ordered (NUM2INT (i)))); 
}

static VALUE view_indexed (int argc, VALUE *argv, VALUE self)
{
    VALUE v1, v2, b;
    rb_scan_args (argc, argv, "21", &v1, &v2, &b);
    if (NIL_P (b))
    {
        b = Qfalse;
    }

    c4_View *view = unwrap<c4_View> (self);
    return wrap_view (new c4_View (view->Indexed (*(unwrap<c4_View> (v1)), *(unwrap<c4_View> (v2)), RTEST (b)))); 
}

static VALUE view_find (int argc, VALUE *argv, VALUE self)
{
    VALUE r, i;
    rb_scan_args (argc, argv, "11", &r, &i);
    if (NIL_P (i))
    {
        i = INT2NUM (0);
    }

    c4_View *view = unwrap<c4_View> (self);
    c4_Row *row   = unwrap<c4_Row> (r);

    return INT2NUM (view->Find (*row, NUM2INT (i)));
}

static VALUE view_search (VALUE self, VALUE r)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_Row *row   = unwrap<c4_Row> (r);

    return INT2NUM (view->Search (*row));
}

static VALUE view_locate (VALUE self, VALUE r)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_Row *row   = unwrap<c4_Row> (r);

    int pos;
    int num = view->Locate (*row, &pos);

    VALUE ary = rb_ary_new (); 
    rb_ary_push (ary, INT2NUM (num));
    rb_ary_push (ary, INT2NUM (pos));

    return ary; 
}

static VALUE view_compare (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *vv = unwrap<c4_View> (v);

    return INT2NUM (view->Compare (*vv));
}

static VALUE view_get_index_of (VALUE self, VALUE r)
{
    c4_View *view = unwrap<c4_View> (self);
    return INT2NUM (view->GetIndexOf ( *(unwrap<c4_Row> (r))));
}

static VALUE view_relocate_rows (VALUE self, VALUE from, VALUE count, VALUE dest, VALUE pos)
{
    c4_View *view = unwrap<c4_View> (self);
    view->RelocateRows (NUM2INT (from),
                        NUM2INT (count),
                        * (unwrap<c4_View> (dest)),
                        NUM2INT (pos));
    return Qnil; 
}

static VALUE view_is_compatible_with (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);
    return ( view->IsCompatibleWith (* (unwrap<c4_View> (v))) ? Qtrue : Qfalse);
}

static VALUE view_equal (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view == *oview) ? Qtrue: Qfalse;
}

static VALUE view_not_equal (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view != *oview) ? Qtrue: Qfalse;
}

static VALUE view_less (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view < *oview) ? Qtrue: Qfalse;
}

static VALUE view_greater (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view > *oview) ? Qtrue: Qfalse;
}

static VALUE view_less_equal (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view <= *oview) ? Qtrue: Qfalse;
}

static VALUE view_greater_equal (VALUE self, VALUE other)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *oview = unwrap<c4_View> (other);

    return (*view >= *oview) ? Qtrue: Qfalse;
}

static VALUE view_set_at_grow (VALUE self, VALUE i, VALUE r)
{
    c4_View *view = unwrap<c4_View> (self);
    view->SetAtGrow (NUM2INT (i), * (unwrap<c4_Row> (r)));
    return Qnil; 
}

static VALUE view_assign (VALUE self, VALUE v)
{
    c4_View *view = unwrap<c4_View> (self);
    c4_View *vv = unwrap<c4_View> (v);

    (*view) = *vv;
    return self; 
}


void init_view ()
{
    // view methods
    rb_define_singleton_method (cView, "new",          (RUBY_CFUNC) view_new,          0); 

    rb_define_method (cView, "add",                     (RUBY_CFUNC) view_add,                     1);
    rb_define_method (cView, "select_range",            (RUBY_CFUNC) view_select_range,            2);
    rb_define_method (cView, "select",                  (RUBY_CFUNC) view_select,                  1);
    rb_define_method (cView, "get_size",                (RUBY_CFUNC) view_get_size,                0);
    rb_define_method (cView, "set_size",                (RUBY_CFUNC) view_set_size,                -1);
    rb_define_method (cView, "remove_all",              (RUBY_CFUNC) view_remove_all,              0);
    rb_define_method (cView, "get_at",                  (RUBY_CFUNC) view_get_at,                  1);
    rb_define_method (cView, "set_at",                  (RUBY_CFUNC) view_set_at,                  2);
    rb_define_method (cView, "set_at_grow",             (RUBY_CFUNC) view_set_at_grow,             2); 
    rb_define_method (cView, "insert_row_at",           (RUBY_CFUNC) view_insert_row_at,           -1);
    rb_define_method (cView, "insert_view_at",          (RUBY_CFUNC) view_insert_view_at,          2);
    rb_define_method (cView, "remove_at",               (RUBY_CFUNC) view_remove_at,               -1);
    
    rb_define_method (cView, "num_properties",          (RUBY_CFUNC) view_num_properties,          0);
    rb_define_method (cView, "description",             (RUBY_CFUNC) view_description,             0);
    
    rb_define_method (cView, "nth_property",            (RUBY_CFUNC) view_nth_property,            1);
    rb_define_method (cView, "find_property",           (RUBY_CFUNC) view_find_property,           1);
    rb_define_method (cView, "find_prop_index_by_name", (RUBY_CFUNC) view_find_prop_index_by_name, 1);
    rb_define_method (cView, "duplicate",               (RUBY_CFUNC) view_duplicate,               0);
    rb_define_method (cView, "clone",                   (RUBY_CFUNC) view_clone,                   0);
    rb_define_method (cView, "add_property",            (RUBY_CFUNC) view_add_property,            1);
    rb_define_method (cView, "comma",                   (RUBY_CFUNC) view_comma,                   1);
    
    rb_define_method (cView, "sort",                    (RUBY_CFUNC) view_sort,                    0);
    rb_define_method (cView, "sort_on",                 (RUBY_CFUNC) view_sort_on,                 1);
    rb_define_method (cView, "sort_on_reverse",         (RUBY_CFUNC) view_sort_on_reverse,         2);
    
    rb_define_method (cView, "project",                 (RUBY_CFUNC) view_project,                 1);
    rb_define_method (cView, "project_without",         (RUBY_CFUNC) view_project_without,         1);
    
    rb_define_method (cView, "slice",                   (RUBY_CFUNC) view_slice,                   -1);
    
    rb_define_method (cView, "product",                 (RUBY_CFUNC) view_product,                 1);
    rb_define_method (cView, "remap_with",              (RUBY_CFUNC) view_remap_with,              1);
    rb_define_method (cView, "pair",                    (RUBY_CFUNC) view_pair,                    1);
    rb_define_method (cView, "concat",                  (RUBY_CFUNC) view_concat,                  1);
    rb_define_method (cView, "rename",                  (RUBY_CFUNC) view_rename,                  2);
    
    rb_define_method (cView, "group_by",                (RUBY_CFUNC) view_group_by,                2);
    rb_define_method (cView, "counts",                  (RUBY_CFUNC) view_counts,                  2);
    rb_define_method (cView, "unique",                  (RUBY_CFUNC) view_unique,                  0);
    
    rb_define_method (cView, "union",                   (RUBY_CFUNC) view_union,                   1);
    rb_define_method (cView, "intersect",               (RUBY_CFUNC) view_intersect,               1);
    rb_define_method (cView, "different",               (RUBY_CFUNC) view_different,               1);
    rb_define_method (cView, "minus",                   (RUBY_CFUNC) view_minus,                   1);
    
    rb_define_method (cView, "join_prop",               (RUBY_CFUNC) view_join_prop,               -1);
    rb_define_method (cView, "join",                    (RUBY_CFUNC) view_join,                    -1);
    
    rb_define_method (cView, "read_only",               (RUBY_CFUNC) view_read_only,               0);
    rb_define_method (cView, "hash",                    (RUBY_CFUNC) view_hash,                    -1);
    rb_define_method (cView, "blocked",                 (RUBY_CFUNC) view_blocked,                 0);
    rb_define_method (cView, "ordered",                 (RUBY_CFUNC) view_ordered,                 -1);
    rb_define_method (cView, "indexed",                 (RUBY_CFUNC) view_indexed,                 -1);
    
    rb_define_method (cView, "find",                    (RUBY_CFUNC) view_find,                    -1);
    rb_define_method (cView, "search",                  (RUBY_CFUNC) view_search,                  1);
    rb_define_method (cView, "locate",                  (RUBY_CFUNC) view_locate,                  1);
    rb_define_method (cView, "compare",                 (RUBY_CFUNC) view_compare,                 1);
    
    rb_define_method (cView, "get_index_of",            (RUBY_CFUNC) view_get_index_of,            1);
    rb_define_method (cView, "relocate_rows",           (RUBY_CFUNC) view_relocate_rows,           4);
    rb_define_method (cView, "is_compatible_with",      (RUBY_CFUNC) view_is_compatible_with,      1);
    
    rb_define_method (cView, "==",                      (RUBY_CFUNC) view_equal,                   1);
    rb_define_method (cView, "!=",                      (RUBY_CFUNC) view_not_equal,               1);
    rb_define_method (cView, "<",                       (RUBY_CFUNC) view_less,                    1);
    rb_define_method (cView, ">",                       (RUBY_CFUNC) view_greater,                 1);
    rb_define_method (cView, "<=",                      (RUBY_CFUNC) view_less_equal,              1);
    rb_define_method (cView, ">=",                      (RUBY_CFUNC) view_greater_equal,           1);
    rb_define_method (cView, "assign", (RUBY_CFUNC) view_assign, 1);


}

//     bool GetItem(int, int, c4_Bytes &)const;
//     void SetItem(int, int, const c4_Bytes &)const;

