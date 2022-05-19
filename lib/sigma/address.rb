require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class Address
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_address_from_testnet, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_from_mainnet, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_from_base58, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_to_base58, [:pointer, Sigma::NETWORK_PREFIX_ENUM, :pointer], :void
    attach_function :ergo_lib_address_delete, [:pointer], :void
    attach_function :ergo_lib_address_type_prefix, [:pointer], :uint8
    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.with_testnet_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_testnet(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def self.with_mainnet_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_mainnet(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def self.with_base58_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_base58(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def to_base58(network_prefix)
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_address_to_base58(self.pointer, network_prefix, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def type_prefix
      ergo_lib_address_type_prefix(self.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_address_delete)
      )
      obj 
    end
  end
end
