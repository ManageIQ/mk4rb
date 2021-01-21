#ifndef __MK4RB__H__
#define __MK4RB__H__

#include "ruby.h"
#include "mk4.h"

// to simplify method casts 
#define RUBY_CFUNC VALUE (*) (ANYARGS)

// Metakit module
extern VALUE mMetakit;

extern VALUE cProperty; 
extern VALUE cIntProp;
extern VALUE cStringProp;
extern VALUE cViewProp;
extern VALUE cFloatProp;
extern VALUE cDoubleProp;
extern VALUE cLongProp; 

extern VALUE cView;
extern VALUE cRowRef; 
extern VALUE cRow;
extern VALUE cStorage;

extern VALUE cStream;
extern VALUE cFileStream; 
extern VALUE cStrategy;

extern VALUE cBytes;
extern VALUE cBytesProp;
extern VALUE cBytesRef;

extern VALUE cCursor; 

void init_prop (); 
void init_intprop ();
void init_strprop ();
void init_viewprop ();
void init_floatprop ();
void init_doubleprop ();
void init_bytesprop ();
void init_cursor ();
void init_longprop (); 

void init_row ();
void init_rowref (); 
void init_view ();
void init_storage ();
void init_stream ();
void init_file_stream ();
void init_strategy ();
void init_bytes ();
void init_bytesref (); 

template <typename T>
inline T* unwrap (VALUE self)
{
    T *result;
    Data_Get_Struct (self, T, result);
    return result;
}

template <typename T>
inline void delete_gc (void *obj)
{
    delete (T *)obj;
}

template <typename T>
inline VALUE wrap (VALUE v, T* obj)
{
    return Data_Wrap_Struct (v, 0, delete_gc<T>, obj); 
}

// just like wrap - but without free function
// usually for something we don't have control of
template <typename T>
inline VALUE wrap_unsafe (VALUE v, const T* obj)
{
    return Data_Wrap_Struct (v, 0, 0, (void *) obj); 
}

inline VALUE wrap_cursor (c4_Cursor* cursor)
{
    return wrap<c4_Cursor> (cCursor, cursor);
}

inline VALUE wrap_row (c4_Row *row)
{
    return wrap<c4_Row> (cRow, row);
}

inline VALUE wrap_bytes (c4_Bytes *bytes)
{
    return wrap<c4_Bytes> (cBytes, bytes);
}

inline VALUE wrap_bytesref (c4_BytesRef *bytes)
{
    return wrap<c4_BytesRef> (cBytesRef, bytes);
}
    
inline VALUE wrap_rowref (c4_RowRef *row)
{
    return wrap<c4_RowRef> (cRowRef, row);
}

inline VALUE wrap_int (c4_IntProp *intProp)
{
    return wrap<c4_IntProp> (cIntProp, intProp);
}

inline VALUE wrap_long (c4_LongProp *intProp)
{
    return wrap<c4_LongProp> (cLongProp, intProp);
}

inline VALUE wrap_bytesprop (c4_BytesProp *bytesProp)
{
    return wrap<c4_BytesProp> (cBytesProp, bytesProp);
}

inline VALUE wrap_float (c4_FloatProp *floatProp)
{
    return wrap<c4_FloatProp> (cFloatProp, floatProp);
}

inline VALUE wrap_double (c4_DoubleProp *dblProp)
{
    return wrap<c4_DoubleProp> (cDoubleProp, dblProp);
}

inline VALUE wrap_str (c4_StringProp *strProp)
{
    return wrap<c4_StringProp> (cStringProp, strProp);
}

inline VALUE wrap_viewprop (c4_ViewProp *viewProp)
{
    return wrap<c4_ViewProp> (cViewProp, viewProp); 
}

inline VALUE wrap_view (c4_View *view)
{
    return wrap<c4_View> (cView, view);
}

inline VALUE wrap_storage (c4_Storage *storage)
{
    return wrap<c4_Storage> (cStorage, storage); 
}

inline VALUE wrap_stream (c4_Stream *stream)
{
    return wrap<c4_Stream> (cStream, stream);
}

#endif // __MK4RB__H__
