#include "mk4rb.h"

VALUE mMetakit;

extern "C" 
void Init_metakit_raw(void)
{    
    mMetakit    = rb_define_module ("Metakit");

    cCursor     = rb_define_class_under (mMetakit, "Cursor",     rb_cObject); 
    cView       = rb_define_class_under (mMetakit, "View",       rb_cObject);
    cStorage    = rb_define_class_under (mMetakit, "Storage",    cView);

    cRowRef     = rb_define_class_under (mMetakit, "RowRef",     rb_cObject); 
    cRow        = rb_define_class_under (mMetakit, "Row",        cRowRef);

    cBytes      = rb_define_class_under (mMetakit, "Bytes",      rb_cObject);
    cBytesRef   = rb_define_class_under (mMetakit, "BytesRef",   rb_cObject); 

    cProperty   = rb_define_class_under (mMetakit, "Property",   rb_cObject); 
    cIntProp    = rb_define_class_under (mMetakit, "IntProp",    cProperty);
    cStringProp = rb_define_class_under (mMetakit, "StringProp", cProperty);
    cViewProp   = rb_define_class_under (mMetakit, "ViewProp",   cProperty);
    cFloatProp  = rb_define_class_under (mMetakit, "FloatProp",  cProperty);
    cDoubleProp = rb_define_class_under (mMetakit, "DoubleProp", cProperty);
    cBytesProp  = rb_define_class_under (mMetakit, "BytesProp",  cProperty);
    cLongProp   = rb_define_class_under (mMetakit, "LongProp",   cProperty); 

    cStream     = rb_define_class_under (mMetakit, "Stream",     rb_cObject);
    cFileStream = rb_define_class_under (mMetakit, "FileStream", cStream); 
    cStrategy   = rb_define_class_under (mMetakit, "Strategy",   rb_cObject);

    init_cursor (); 
    init_bytes ();
    init_bytesref (); 
    
    init_prop ();
    init_intprop ();
    init_strprop ();
    init_viewprop ();
    init_floatprop ();
    init_doubleprop ();
    init_bytesprop ();
    init_longprop (); 

    init_rowref (); 
    init_row ();
    init_view (); 
    init_storage ();
    init_stream ();
    init_file_stream (); 
    init_strategy (); 
}
