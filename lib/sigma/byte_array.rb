require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Array of Bytes
  class ByteArray
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_byte_array_delete, [:pointer], :void
    attach_function :ergo_lib_byte_array_from_raw_parts, [:pointer, :uint, :pointer], :error_pointer
    attr_accessor :pointer

    # Create ByteArray of Array of unsigned 8-bit ints (bytes)
    # @param bytes [Array<uint8>] Array of 8-bit integers (0-255)
    # @return [ByteArray]
    def self.from_bytes(bytes)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_byte_array_from_raw_parts(b_ptr, bytes.size, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Takes ownership of an existing ByteArray Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ByteArray]
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

  # An ordered collection of ByteArray
  class ByteArrays
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_byte_arrays_new, [:pointer], :void
    attach_function :ergo_lib_byte_arrays_delete, [:pointer], :void
    attach_function :ergo_lib_byte_arrays_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_byte_arrays_len, [:pointer], :uint8
    attach_function :ergo_lib_byte_arrays_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing ByteArrays Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ByteArrays]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [ByteArrays]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_byte_arrays_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_byte_arrays_len(self.pointer)
    end

    # Add an item to collection
    # @param byte_array [ByteArray]
    def add(byte_array)
      ergo_lib_byte_arrays_add(byte_array.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @params index [Integer]
    # @return [ByteArray, nil]
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

