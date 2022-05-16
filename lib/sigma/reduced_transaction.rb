require 'ffi'
require_relative './util.rb'

module Sigma
  class ReducedTransaction
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_reduced_tx_delete, [:pointer], :void
    attach_function :ergo_lib_reduced_tx_from_unsigned_tx, [:pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_reduced_tx_unsigned_tx, [:pointer, :pointer], :void
    attr_accessor :pointer

    def self.from_unsigned_tx(unsigned_tx:, boxes_to_spend:, data_boxes:, state_context:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_reduced_tx_from_unsigned_tx(
          unsigned_tx.pointer,
          boxes_to_spend.pointer,
          data_boxes.pointer,
          state_context.pointer,
          pointer
        )
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_unsigned_transaction
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_reduced_tx_unsigned_tx(self.pointer, pointer)
      UnsignedTransaction.with_raw_pointer(pointer)
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_reduced_tx_delete)
      )
      obj 
    end
  end

  class Propositions
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_propositions_delete, [:pointer], :void
    attach_function :ergo_lib_propositions_new, [:pointer], :void
    attach_function :ergo_lib_propositions_add_proposition_from_bytes, [:pointer, :pointer, :uint], :error_pointer
    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_propositions_new(pointer)
      init(pointer)
    end

    def add_proposition(bytes)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_propositions_add_proposition_from_bytes(self.pointer, b_ptr, bytes.size)
      Util.check_error!(error)
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_propositions_delete)
      )
      obj 
    end
  end
end

