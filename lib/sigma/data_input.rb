require 'ffi'
require_relative './util.rb'

module Sigma
  class DataInput
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_data_input_new, [:pointer, :pointer], :void
    attach_function :ergo_lib_data_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_data_input_delete, [:pointer], :void
    attr_accessor :pointer

    def self.with_box_id(box_id)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_data_input_new(box_id.pointer, pointer) 
      init(pointer)
    end
  
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_data_input_new(self.pointer, pointer) 
      Sigma::BoxId.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_data_input_delete)
      )
      obj 
    end

  end

  class DataInputs
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attr_accessor :pointer

  end
end
