require 'ffi'
require_relative './util.rb'

module Sigma
  class SecretKey
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_secret_key_delete, [:pointer], :void
    attach_function :ergo_lib_secret_key_generate_random, [:pointer], :void
    attach_function :ergo_lib_secret_key_from_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_secret_key_get_address, [:pointer, :pointer], :void
    attach_function :ergo_lib_secret_key_to_bytes, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_secret_key_generate_random(pointer)
      init(pointer)
    end

    def self.from_bytes(bytes)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_secret_key_from_bytes(b_ptr, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.from_raw_pointer(pointer)
      init(pointer)
    end

    def get_address
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_secret_key_get_address(self.pointer, pointer)
      Sigma::Address.with_raw_pointer(pointer)
    end

    def to_bytes
      bytes_len = 32
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes_len) 
      ergo_lib_secret_key_to_bytes(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, bytes_len)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_secret_key_delete)
      )
      obj
    end
  end

  # TODO
  class SecretKeys
  end
end
