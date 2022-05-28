require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class Wallet
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_wallet_delete, [:pointer], :void
    attach_function :ergo_lib_wallet_from_secrets, [:pointer, :pointer], :void
    attach_function :ergo_lib_wallet_from_mnemonic, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_sign_transaction, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_sign_transaction_multi, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_sign_reduced_transaction, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_sign_reduced_transaction_multi, [:pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_generate_commitments, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_generate_commitments_for_reduced_transaction, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_wallet_add_secret, [:pointer, :pointer], :error_pointer
    attr_accessor :pointer

    # Create Wallet instance loading secret key from mnemonic. Throws error if a DlogSecretKey cannot be
    # parsed from the provided phrase
    # @param mnemonic_phrase [String]
    # @param mnemonic_pass [String]
    # @return [Wallet]
    def self.create_from_mnemonic(mnemonic_phrase, mnemonic_pass)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_from_mnemonic(mnemonic_phrase, mnemonic_pass, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Create Wallet from secrets
    # @param secrets [SecretKeys]
    # @return [Wallet]
    def self.create_from_secrets(secrets)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_wallet_from_secrets(secrets.pointer, pointer)
      init(pointer)
    end

    # Add a secret to the wallet's prover
    # @param secret [SecretKey]
    def add_secret(secret)
      error = ergo_lib_wallet_add_secret(self.pointer, secret.pointer)
      Util.check_error!(error)
    end
  
    # Sign a transaction
    # @param state_context: [ErgoStateContext]
    # @param unsigned_tx: [UnsignedTransaction]
    # @param boxes_to_spend: [ErgoBoxes]
    # @param data_boxes: [ErgoBoxes]
    # @return [Transaction]
    def sign_transaction(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_transaction(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    # Sign a multi-signature transaction
    # @param state_context: [ErgoStateContext]
    # @param unsigned_tx: [UnsignedTransaction]
    # @param boxes_to_spend: [ErgoBoxes]
    # @param data_boxes: [ErgoBoxes]
    # @param tx_hints: [TransactionHintsBag]
    # @return [Transaction]
    def sign_transaction_multi(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:, tx_hints:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_transaction_multi(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, tx_hints.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    # Signs a reduced transaction (generating proofs for inputs)
    # @param reduced_tx [ReducedTransaction]
    # @return [Transaction]
    def sign_reduced_transaction(reduced_tx)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_reduced_transaction(self.pointer, reduced_tx.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    # Signs a multi signature reduced transaction
    # @param reduced_tx [ReducedTransaction]
    # @param tx_hints: [TransactionHintsBag]
    # @return [Transaction]
    def sign_reduced_transaction_multi(reduced_tx:, tx_hints:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_reduced_transaction_multi(self.pointer, reduced_tx.pointer, tx_hints.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    # Generate Commitments for unsigned tx
    # @param state_context: [ErgoStateContext]
    # @param unsigned_tx: [UnsignedTransaction]
    # @param boxes_to_spend: [ErgoBoxes]
    # @param data_boxes: [ErgoBoxes]
    # @return [TransactionHintsBag]
    def generate_commitments(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_generate_commitments(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, pointer)
      Util.check_error!(error)
      Sigma::TransactionHintsBag.with_raw_pointer(pointer)
    end

    # Generate Commitments for reduced transaction
    # @param reduced_tx [ReducedTransaction]
    # @return [TransactionHintsBag]
    def generate_commitments_for_reduced_transaction(reduced_tx)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_generate_commitments_for_reduced_transaction(self.pointer, reduced_tx.pointer, pointer)
      Util.check_error!(error)
      Sigma::TransactionHintsBag.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_wallet_delete)
      )
      obj
    end
  end
end


