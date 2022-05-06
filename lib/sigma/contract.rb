require 'ffi'
require_relative './util.rb'

module Sigma
  class Contract
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer
    attach_function :ergo_lib_contract_delete, [:pointer], :void
    attach_function :ergo_lib_contract_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_contract_new, [:pointer, :pointer], :void
    attach_function :ergo_lib_contract_compile, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_contract_pay_to_address, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_contract_ergo_tree, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.with_raw_pointer(contract_pointer)
      init(contract_pointer)
    end
  
    def self.from_ergo_tree(ergo_tree)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_contract_new(ergo_tree.pointer, pointer)

      init(pointer) 
    end

    def self.compile_from_string(str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_contract_compile(str, pointer)
      Util.check_error!(error)
      
      init(pointer)
    end

    def self.pay_to_address(address)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_contract_pay_to_address(address.pointer, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def get_ergo_tree
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_contract_ergo_tree(self.pointer, pointer)
      Sigma::ErgoTree.with_raw_pointer(pointer)
    end

    def ==(contract_two)
      ergo_lib_contract_eq(self.pointer, contract_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_contract_delete)
      )
      obj
    end
  end
end

