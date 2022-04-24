require 'ffi'
require_relative './error.rb'
module Sigma

  class Constant
    attr_accessor :ptr

    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_lib_constant_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_constant_from_base16, [:string, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_i32, [:int32, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_constant_to_base16, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_bytes, [:pointer, :uint, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_ecpoint_bytes, [:pointer, :uint, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_ergo_box, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_constant_delete, [:pointer], :void

    def initialize(constant_pointer)
      # Convert to FFI::Pointer
      c_ptr = constant_pointer.get_pointer(0)

      # Set pointer release function and save to self.ptr
      self.ptr = FFI::AutoPointer.new(
        c_ptr,
        method(:ergo_lib_constant_delete)
      )
    end

    def self.with_ergo_box(ergo_box)
      # TODO
    end

    def self.with_bytes(bytes)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_constant_from_bytes(b_ptr, bytes.size, c_ptr)
      Error.check_error!(error)

      self.new(c_ptr)
    end

    def self.with_ecpoint_bytes(bytes)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_constant_from_ecpoint_bytes(b_ptr, bytes.size, c_ptr)
      Error.check_error!(error)

      self.new(c_ptr)
    end

    def to_base16_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_constant_to_base16(self.ptr, s_ptr)
      Error.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      s_ptr.null? ? nil : s_ptr.read_string().force_encoding('UTF-8')
    end

    def self.with_int(int)
      error = nil
      bl = int.bit_length
      c_ptr = FFI::MemoryPointer.new(:pointer)
      if bl <= 32
        error = ergo_lib_constant_from_i32(int, c_ptr)
        #c.ptr = c.ptr.get_pointer(0)
      elsif bl <= 64
        error = ergo_lib_constant_from_i64(int, c_ptr)
      else
        raise ArgumentError.new('Only support 32bit and 64bit integers.')
      end
      # TODO: This raises error even with valid output
      #Error.check_error!(error)

      self.new(c_ptr)
    end

    def self.with_base_16(str)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_constant_from_base16(str, c_ptr)
      Error.check_error!(error)

      self.new(c_ptr)
    end

    def ==(constant_two)
      ergo_lib_constant_eq(self.ptr, constant_two.ptr)
    end
  end
end
