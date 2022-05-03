require 'ffi'
require_relative './util.rb'

module Sigma
  class Contract
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer
    attach_function :ergo_lib_contract_delete, [:pointer], :void
    attach_function :ergo_lib_contract_new, [:pointer, :pointer], :void
    attach_function :ergo_lib_contract_compile, [:pointer, :pointer], :error_pointer

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

