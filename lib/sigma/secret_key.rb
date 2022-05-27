require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Secret key for the prover
  class SecretKey
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_secret_key_delete, [:pointer], :void
    attach_function :ergo_lib_secret_key_generate_random, [:pointer], :void
    attach_function :ergo_lib_secret_key_from_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_secret_key_get_address, [:pointer, :pointer], :void
    attach_function :ergo_lib_secret_key_to_bytes, [:pointer, :pointer], :void

    attr_accessor :pointer

    # Generate random key
    # @return [SecretKey]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_secret_key_generate_random(pointer)
      init(pointer)
    end

    # Parse dlog secret key from bytes (SEC-1-encoded scalar)
    # @param bytes [Array<uint8>] Array of 8-bit integers (0-255)
    # @return [SecretKey]
    def self.from_bytes(bytes)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_secret_key_from_bytes(b_ptr, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Takes ownership of an existing SecretKey Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [SecretKey]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get address (encoded public image)
    # @return [Address]
    def get_address
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_secret_key_get_address(self.pointer, pointer)
      Sigma::Address.with_raw_pointer(pointer)
    end
    
    # Encode to bytes
    # @return [Array<uint8>] Array of 8-bit integers (0-255)
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

  # An ordered collection of SecretKey
  class SecretKeys
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_secret_keys_new, [:pointer], :void
    attach_function :ergo_lib_secret_keys_delete, [:pointer], :void
    attach_function :ergo_lib_secret_keys_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_secret_keys_len, [:pointer], :uint8
    attach_function :ergo_lib_secret_keys_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing SecretKeys Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [SecretKeys]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [SecretKeys]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_secret_keys_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_secret_keys_len(self.pointer)
    end

    # Add to collection
    # @param secret_key [SecretKey]
    def add(secret_key)
      ergo_lib_secret_keys_add(secret_key.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [SecretKey, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_secret_keys_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::SecretKey.with_raw_pointer(pointer)
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
        method(:ergo_lib_secret_keys_delete)
      )
      obj
    end
  end
end
