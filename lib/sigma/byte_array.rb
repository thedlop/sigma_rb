require 'ffi'
require_relative './util.rb'

module Sigma
  class ByteArray
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_byte_array_delete, [:pointer], :void
    attach_function :ergo_lib_byte_array_from_raw_parts, [:pointer, :uint, :pointer], :error_pointer
    attr_accessor :pointer

    def self.from_bytes(bytes)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_byte_array_from_raw_parts(b_ptr, bytes.size, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_byte_array_delete)
      )
      obj
    end
  end

  class ByteArrays
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_byte_arrays_new, [:pointer], :void
    attach_function :ergo_lib_byte_arrays_delete, [:pointer], :void
    attach_function :ergo_lib_byte_arrays_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_byte_arrays_len, [:pointer], :uint8
    attach_function :ergo_lib_byte_arrays_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_byte_arrays_new(pointer)

      init(pointer)
    end

    def len
      ergo_lib_byte_arrays_len(self.pointer)
    end

    def add(byte_array)
      ergo_lib_byte_arrays_add(byte_array.pointer, self.pointer)
    end

    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_byte_arrays_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::ByteArray.with_raw_pointer(pointer)
      else
        nil
      end
    end
    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_byte_arrays_delete)
      )
      obj
    end
  end
end

