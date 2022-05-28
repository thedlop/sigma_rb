require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Defines the contract (script) that will be guarding box contents
  class Contract
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_contract_delete, [:pointer], :void
    attach_function :ergo_lib_contract_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_contract_new, [:pointer, :pointer], :void
    attach_function :ergo_lib_contract_compile, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_contract_pay_to_address, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_contract_ergo_tree, [:pointer, :pointer], :void

    attr_accessor :pointer

    # Takes ownership of an existing Contract Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Contract]
    def self.with_raw_pointer(contract_pointer)
      init(contract_pointer)
    end
  
    # Create a new contract from an ErgoTree
    # @param ergo_tree [ErgoTree]
    # @return [Contract]
    def self.from_ergo_tree(ergo_tree)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_contract_new(ergo_tree.pointer, pointer)

      init(pointer) 
    end

    # Compiles a contract from ErgoScript source code
    # @param source [String]
    # @return [Contract]
    def self.compile_from_string(source)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_contract_compile(source, pointer)
      Util.check_error!(error)
      
      init(pointer)
    end

    # Create new contract that allow spending of the guarded box by a given recipient (Address)
    # @param address [Address]
    # @return [Contract]
    def self.pay_to_address(address)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_contract_pay_to_address(address.pointer, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Get the ErgoTree of the contract
    # @return [ErgoTree]
    def get_ergo_tree
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_contract_ergo_tree(self.pointer, pointer)
      Sigma::ErgoTree.with_raw_pointer(pointer)
    end

    # Equality check for two Contracts
    # @param contract_two [Contract]
    # @return [bool]
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

