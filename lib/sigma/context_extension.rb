require 'ffi'
require_relative './util.rb'

module Sigma
  class ContextExtension
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_context_extension_delete, [:pointer], :void
    attach_function :ergo_lib_context_extension_empty, [:pointer], :void
    attach_function :ergo_lib_context_extension_len, [:pointer], :uint
    attach_function :ergo_lib_context_extension_keys, [:pointer, :pointer], :void
    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_context_extension_empty(pointer)
      init(pointer) 
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_keys
      ce_len = ergo_lib_context_extension_len(self.pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, ce_len)
      ergo_lib_context_extension_keys(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, ce_len) 
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_context_extension_delete)
      )
      obj 
    end
  end
end

