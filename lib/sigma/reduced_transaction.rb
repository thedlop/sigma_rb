require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Represent `reduced` transaction, i.e. unsigned transaction where each unsigned input
  # is augmented with ReducedInput which contains a script reduction result.
  # After an unsigned transaction is reduced it can be signed without context.
  # Thus, it can be serialized and transferred for example to Cold Wallet and signed
  # in an environment where secrets are known.
  # see EIP-19 for more details
  # @see https://github.com/ergoplatform/eips/blob/f280890a4163f2f2e988a0091c078e36912fc531/eip-0019.md EIP-19
  class ReducedTransaction
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_reduced_tx_delete, [:pointer], :void
    attach_function :ergo_lib_reduced_tx_from_unsigned_tx, [:pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_reduced_tx_unsigned_tx, [:pointer, :pointer], :void
    attr_accessor :pointer

    # Create `reduced` transaction, i.e. unsigned transaction where each unsigned input
    # is augmented with ReducedInput which contains a script reduction result.
    # @param unsigned_tx: [UnsignedTransaction]
    # @param boxes_to_spend: [ErgoBoxes]
    # @param data_boxes: [ErgoBoxes]
    # @param state_context: [ErgoStateContext]
    # @return [ReducedTransaction]
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

    # Takes ownership of an existing ReducedTransaction Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ReducedTransaction]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get unsigned transaction
    # @return [UnsignedTransaction]
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

  # Propositions list (public keys)
  class Propositions
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_propositions_delete, [:pointer], :void
    attach_function :ergo_lib_propositions_new, [:pointer], :void
    attach_function :ergo_lib_propositions_add_proposition_from_bytes, [:pointer, :pointer, :uint], :error_pointer
    attr_accessor :pointer

    # Create an empty collection
    # @return [Propositions]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_propositions_new(pointer)
      init(pointer)
    end

    # Add a proposition
    # @param bytes [Array<uint8>] Array of 8-bit integers (0-255)
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

