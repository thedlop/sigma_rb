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

    def self.create_from_mnemonic(mnemonic_phrase, mnemonic_pass)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_from_mnemonic(mnemonic_phrase, mnemonic_pass, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.create_from_secrets(secrets)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_wallet_from_secrets(secrets.pointer, pointer)
      init(pointer)
    end

    def add_secret(secret)
      error = ergo_lib_wallet_add_secret(self.pointer, secret.pointer)
      Util.check_error!(error)
    end
  
    def sign_transaction(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_transaction(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    def sign_transaction_multi(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:, tx_hints:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_transaction_multi(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, tx_hints.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    def sign_reduced_transaction(reduced_tx)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_reduced_transaction(self.pointer, reduced_tx.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    def sign_reduced_transaction_multi(reduced_tx:, tx_hints:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_sign_reduced_transaction_multi(self.pointer, reduced_tx.pointer, tx_hints.pointer, pointer)
      Util.check_error!(error)
      Sigma::Transaction.with_raw_pointer(pointer)
    end

    def generate_commitments(state_context:, unsigned_tx:, boxes_to_spend:, data_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_wallet_generate_commitments(self.pointer, state_context.pointer, unsigned_tx.pointer, boxes_to_spend.pointer, data_boxes.pointer, pointer)
      Util.check_error!(error)
      Sigma::TransactionHintsBag.with_raw_pointer(pointer)
    end

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


