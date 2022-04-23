require 'ffi'
require_relative './error.rb'
module Sigma

  class Constant
    # FFI::Pointer
    attr_accessor :ptr

    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_constant_eq, :ergo_lib_constant_eq, [:pointer, :pointer], :bool
    attach_function :ergo_constant_from_base16, :ergo_lib_constant_from_base16, [:string, :pointer], :error_pointer
    attach_function :ergo_constant_from_i32, :ergo_lib_constant_from_i32, [:int32, :pointer], :error_pointer
    attach_function :ergo_constant_from_i64, :ergo_lib_constant_from_i64, [:int64, :pointer], :error_pointer
    #attach_function :ergo_constant_to_base16, :ergo_lib_constant_to_base16, [:pointer, ConstantStrPtr], :error_pointer
    attach_function :ergo_constant_to_base16, :ergo_lib_constant_to_base16, [:pointer, :pointer], :error_pointer

    def self.with_bytes(bytes)
    end

    def to_base16_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_constant_to_base16(self.ptr, s_ptr)
      strPtr = s_ptr.read_pointer() 
      Error.check_error!(error)
      return strPtr.null? ? nil : strPtr.read_string().force_encoding('UTF-8')
    end

    def self.with_int(int)
      c = self.new
      error = nil
      bl = int.bit_length
      c.ptr = FFI::MemoryPointer.new(:pointer)
      if bl <= 32
        error = ergo_constant_from_i32(int, c.ptr)
        c.ptr = c.ptr.get_pointer(0)
      elsif bl <= 64
        error = ergo_constant_from_i64(int, c.ptr)
        c.ptr = c.ptr.get_pointer(0)
      else
        raise ArgumentError.new('Only support 32bit and 64bit integers.')
      end
      c
    end

    def self.with_base_16(str)
      c = self.new
      c.ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_constant_from_base16(str, c.ptr)
      c.ptr = c.ptr.get_pointer(0)
      Error.check_error!(error)
      c
    end

    def ==(constant_two)
      ergo_constant_eq(self.ptr, constant_two.ptr)
    end
  end
end
