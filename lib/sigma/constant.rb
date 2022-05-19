require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class Constant
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_constant_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_constant_from_base16, [:string, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_i32, [:int32, :pointer], :error_pointer
    attach_function :ergo_lib_constant_to_i32, [:pointer], ReturnNumI32.by_value
    attach_function :ergo_lib_constant_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_constant_to_i64, [:pointer], ReturnNumI64.by_value
    attach_function :ergo_lib_constant_to_base16, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_bytes, [:pointer, :uint, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_ecpoint_bytes, [:pointer, :uint, :pointer], :error_pointer
    attach_function :ergo_lib_constant_from_ergo_box, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_constant_delete, [:pointer], :void
    attr_accessor :pointer

    def self.with_ergo_box(ergo_box)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_constant_from_ergo_box(ergo_box.pointer, c_ptr)
      
      init(c_ptr)
    end

    def self.with_bytes(bytes)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_constant_from_bytes(b_ptr, bytes.size, c_ptr)
      Util.check_error!(error)

      init(c_ptr)
    end

    def self.with_ecpoint_bytes(bytes)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_constant_from_ecpoint_bytes(b_ptr, bytes.size, c_ptr)
      Util.check_error!(error)

      init(c_ptr)
    end

    def self.with_raw_pointer(constant_pointer)
      init(constant_pointer)
    end

    def to_base16_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_constant_to_base16(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def self.with_i32(int)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_constant_from_i32(int, pointer)
      # TODO: This raises error even with valid output
      #Util.check_error!(error)
      init(pointer)
    end

    def self.with_i64(int)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_constant_from_i64(int, pointer)
      # TODO: This raises error even with valid output
      #Util.check_error!(error)
      init(pointer)
    end

    def self.with_base_16(str)
      c_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_constant_from_base16(str, c_ptr)
      Util.check_error!(error)

      init(c_ptr)
    end

    def to_i32
      res = ergo_lib_constant_to_i32(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    def to_i64
      res = ergo_lib_constant_to_i64(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    def ==(constant_two)
      ergo_lib_constant_eq(self.pointer, constant_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_constant_delete)
      )
      obj 
    end
  end
end
