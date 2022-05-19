require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class Transaction
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tx_delete, [:pointer], :void
    attach_function :ergo_lib_tx_from_unsigned_tx, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_data_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_output_candidates, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_outputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_to_json_eip12, [:pointer, :pointer], :error_pointer
    attr_accessor :pointer

    def self.create_from_unsigned_tx(unsigned_tx:, proofs:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_from_unsigned_tx(unsigned_tx.pointer, proofs.pointer, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.create_from_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_tx_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_id(self.pointer, pointer)
      Sigma::TxId.with_raw_pointer(pointer)
    end

    def get_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_inputs(self.pointer, pointer)
      Sigma::Inputs.with_raw_pointer(pointer)
    end

    def get_data_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_data_inputs(self.pointer, pointer)
      Sigma::DataInputs.with_raw_pointer(pointer)
    end

    def get_output_candidates
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_output_candidates(self.pointer, pointer)
      Sigma::ErgoBoxCandidates.with_raw_pointer(pointer)
    end

    def get_outputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_outputs(self.pointer, pointer)
      Sigma::ErgoBoxes.with_raw_pointer(pointer)
    end

    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_tx_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def to_json_eip12
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_tx_to_json_eip12(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_tx_delete)
      )
      obj
    end
  end

  class CommitmentHint
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_commitment_hint_delete, [:pointer], :void
    attr_accessor :pointer

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_commitment_hint_delete)
      )
      obj
    end
  end

  class HintsBag
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_hints_bag_delete, [:pointer], :void
    attach_function :ergo_lib_hints_bag_empty, [:pointer], :void
    attach_function :ergo_lib_hints_bag_add_commitment, [:pointer, :pointer], :void
    attach_function :ergo_lib_hints_bag_len, [:pointer], :uint
    attach_function :ergo_lib_hints_bag_get, [:pointer, :uint, :pointer], ReturnOption.by_value
    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_hints_bag_empty(pointer)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def add_commitment_hint(commitment_hint)
      ergo_lib_hints_bag_add_commitment(self.pointer, commitment_hint.pointer)
    end

    def len
      ergo_lib_hints_bag_add_commitment_len(self.pointer)
    end

    def get_commitment_hint(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_hints_bag_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::CommitmentHint.with_raw_pointer(pointer)
      else
        nil
      end
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_hints_bag_delete)
      )
      obj
    end
  end

  class TransactionHintsBag
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_transaction_hints_bag_delete, [:pointer], :void
    attach_function :ergo_lib_transaction_hints_bag_empty, [:pointer], :void
    attach_function :ergo_lib_transaction_hints_bag_add_hints_for_input, [:pointer, :uint, :pointer], :void
    attach_function :ergo_lib_transaction_hints_bag_all_hints_for_input, [:pointer, :uint, :pointer], :void
    attach_function :ergo_lib_transaction_extract_hints, [:pointer, :pointer, :pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer
    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_transaction_hints_bag_empty(pointer)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def self.extract_hints_from_signed_transaction(transaction:, state_context:, boxes_to_spend:, data_boxes:, real_propositions:, simulated_propositions:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_transaction_extract_hints(transaction.pointer, state_context.pointer, boxes_to_spend.pointer, data_boxes.pointer, real_propositions.pointer, simulated_propositions.pointer, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def add_hints_for_input(index:, hints_bag:)
      ergo_lib_transaction_hints_bag_add_hints_for_input(self.pointer, index, hints_bag.pointer)
    end

    def all_hints_for_input(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_transaction_hints_bag_all_hints_for_input(self.pointer, index, pointer)
      Sigma::HintsBag.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_transaction_hints_bag_delete)
      )
      obj
    end
  end

  class UnsignedTransaction
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_unsigned_tx_delete, [:pointer], :void
    attach_function :ergo_lib_unsigned_tx_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_unsigned_tx_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_tx_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_tx_data_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_tx_output_candidates, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_tx_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_unsigned_tx_to_json_eip12, [:pointer, :pointer], :error_pointer
    attr_accessor :pointer

    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_unsigned_tx_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_tx_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_id(self.pointer, pointer)
      Sigma::TxId.with_raw_pointer(pointer)
    end

    def get_unsigned_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_inputs(self.pointer, pointer)
      Sigma::UnsignedInputs.with_raw_pointer(pointer)
    end

    def get_data_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_data_inputs(self.pointer, pointer)
      Sigma::DataInputs.with_raw_pointer(pointer)
    end

    def get_output_candidates
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_output_candidates(self.pointer, pointer)
      Sigma::ErgoBoxCandidates.with_raw_pointer(pointer)
    end

    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_unsigned_tx_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def to_json_eip12
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_unsigned_tx_to_json_eip12(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_unsigned_tx_delete)
      )
      obj
    end
  end

  class TxId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tx_id_delete, [:pointer], :void
    attach_function :ergo_lib_tx_id_from_str, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_id_to_str, [:pointer,:pointer], :error_pointer
  
    attr_accessor :pointer

    def self.with_string(str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_id_from_str(str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def to_s
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_tx_id_to_str(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_tx_id_delete)
      )
      obj 
    end
  end

end

