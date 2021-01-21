#
# mk4rb ruby methods are defined here
# 
require 'metakit_raw'

module Metakit
  class Property
    alias_method :get_id, :metakit_id
    
    def to_view
      View[self]
    end
  end
  
  [IntProp, StringProp, FloatProp, DoubleProp, ViewProp, BytesProp].each {|klass| 
    klass.instance_eval {
      alias_method :[], :as_row

      def self.[] *symbols
        symbols.map {|s| new s.to_s }
      end        
    }
  }
  
  class View
    alias_method :[],         :get_at
    alias_method :[]=,        :set_at
    alias_method :element_at, :get_at
    
    def self.[] *props
      v = new
      props.each {|p|
        v.add_property p
      }
      v
    end
    
    def to_view
      self
    end
  end
  
  class FileStream
    def self.open filename, mode
      f = new(filename, mode)
      return f unless block_given?
      
      r = nil
      begin
        r = yield f
      ensure
        f.close!
      end
      r
    end
  end
  
  class Storage
    # File::open-like semantics - open storage and auto close! it after the block 
    def self.open filename, mode, &b
      s = new(filename, mode)
      return s if b.nil?
      
      s.autoclose &b
    end
    
    # same as open but uses default_new to initialize storage
    def self.create &b
      s = default_new
      return s if b.nil?
      
      s.autoclose &b
    end

    # evaluate a block and auto-destroy
    def autoclose
      r = nil
      begin
        r = yield self
      ensure
        close!
      end
    end      
  end    
end
