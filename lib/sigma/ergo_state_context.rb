require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class ErgoStateContext
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_state_context_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_state_context_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_state_context_new, [:pointer, :pointer, :pointer], :error_pointer

    attr_accessor :pointer

    def self.create(pre_header:, headers:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_state_context_new(pre_header.pointer, headers.pointer, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def ==(esc_two)
      ergo_lib_ergo_state_context_eq(self.pointer, esc.pointer)
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_state_context_delete)
      )
      obj 
    end
  end
end

