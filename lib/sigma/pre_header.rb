require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Block header with the current `spendingTransaction`, that can be predicted by a miner before its formation
  class PreHeader
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_preheader_delete, [:pointer], :void
    attach_function :ergo_lib_preheader_from_block_header, [:pointer, :pointer], :void
    attach_function :ergo_lib_pre_header_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    # Create using data from block_header
    # @param block_header [BlockHeader]
    # @return [PreHeader]
    def self.with_block_header(block_header)
      pointer = FFI::MemoryPointer.new(:pointer) 
      ergo_lib_preheader_from_block_header(block_header.pointer, pointer)
      init(pointer) 
    end

    # Equality check
    # @param ph_two [PreHeader]
    # @return [bool]
    def ==(ph_two)
      ergo_lib_pre_header_eq(self.pointer, ph_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_preheader_delete)
      )
      obj
    end
  end
end
