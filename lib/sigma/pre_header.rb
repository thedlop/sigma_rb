
require 'ffi'
require_relative './util.rb'

module Sigma
  class PreHeader
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_preheader_delete, [:pointer], :void
    attach_function :ergo_lib_preheader_from_block_header, [:pointer, :pointer], :void
    attach_function :ergo_lib_pre_header_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    def self.with_block_header(block_header)
      pointer = FFI::MemoryPointer.new(:pointer) 
      ergo_lib_preheader_from_block_header(block_header.pointer, pointer)
      init(pointer) 
    end

    def ==(ph_two)
      ergo_lib_pre_header_eq(self.pointer, ph_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_preheader_delete)
      )
      obj
    end
  end
end
