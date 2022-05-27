require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma

  # ErgoTransaction is an atomic state transition operation. It destroys Boxes from the state
  # and creates new ones. If transaction is spending boxes protected by some non-trivial scripts,
  # its inputs should also contain proof of spending correctness - context extension (user-defined
  # key-value map) and data inputs (links to existing boxes in the state) that may be used during
  # script reduction to crypto, signatures that satisfies the remaining cryptographic protection
  # of the script.
  # Transactions are not encrypted, so it is possible to browse and view every transaction ever
  # collected into a block.
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

    # Create ``Transaction`` from ``UnsignedTransaction`` and an array of proofs in the same order
    # as `UnsignedTransaction.inputs` with empty proof indicated with empty byte array
    # @param unsigned_tx: [UnsignedTransaction]
    # @param proofs: [ByteArrays]
    # @return [Transaction]
    def self.create_from_unsigned_tx(unsigned_tx:, proofs:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_from_unsigned_tx(unsigned_tx.pointer, proofs.pointer, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Parse from JSON. Supports Ergo Node/Explorer API and box values and token amount encoded as strings
    # @param json [String]
    # @return [Transaction]
    def self.create_from_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Takes ownership of an existing Transaction Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Transaction]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get transaction id
    # @return [TxId]
    def get_tx_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_id(self.pointer, pointer)
      Sigma::TxId.with_raw_pointer(pointer)
    end

    # Get inputs
    # @return [Inputs]
    def get_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_inputs(self.pointer, pointer)
      Sigma::Inputs.with_raw_pointer(pointer)
    end

    # Get data inputs
    # @return [DataInputs]
    def get_data_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_data_inputs(self.pointer, pointer)
      Sigma::DataInputs.with_raw_pointer(pointer)
    end

    # Get output candidates
    # @return [ErgoBoxCandidates]
    def get_output_candidates
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_output_candidates(self.pointer, pointer)
      Sigma::ErgoBoxCandidates.with_raw_pointer(pointer)
    end

    # Get outputs
    # @return [ErgoBoxes]
    def get_outputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_outputs(self.pointer, pointer)
      Sigma::ErgoBoxes.with_raw_pointer(pointer)
    end

    # JSON representation as text (compatible with Ergo Node/Explorer API, numbers are encoded as numbers)
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_tx_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # JSON representation according to EIP-12 
    # @see https://github.com/ergoplatform/eips/pull/23 EIP-12
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

  # A family of hints which are about a correspondence between a public image of a secret image and prover's commitment
  # to randomness ("a" in a sigma protocol).
  class CommitmentHint
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_commitment_hint_delete, [:pointer], :void
    attr_accessor :pointer

    # Takes ownership of an existing CommitmentHint Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [CommitmentHint]
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

  # Collection of hints to be used by prover
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

    # Create an empty collection
    # @return [HintsBag]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_hints_bag_empty(pointer)
      init(pointer)
    end

    # Takes ownership of an existing HintsBag Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [HintsBag]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Add to collection
    # @param commitment_hint [CommitmentHint]
    def add_commitment_hint(commitment_hint)
      ergo_lib_hints_bag_add_commitment(self.pointer, commitment_hint.pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_hints_bag_add_commitment_len(self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [CommitmentHint, nil]
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

    # Create empty collection
    # @return [TransactionHintsBag]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_transaction_hints_bag_empty(pointer)
      init(pointer)
    end

    # Takes ownership of an existing TransactionHintsBag Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [TransactionHintsBag]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Extract hints from signed transaction
    # @param transaction: [Transaction]
    # @param state_context: [ErgoStateContext]
    # @param boxes_to_spend: [ErgoBoxes]
    # @param data_boxes: [ErgoBoxes]
    # @param real_propositions: [Propositions]
    # @param simulated_propositions: [Propositions]
    # @return [TransactionHintsBag]
    def self.extract_hints_from_signed_transaction(transaction:, state_context:, boxes_to_spend:, data_boxes:, real_propositions:, simulated_propositions:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_transaction_extract_hints(transaction.pointer, state_context.pointer, boxes_to_spend.pointer, data_boxes.pointer, real_propositions.pointer, simulated_propositions.pointer, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Add hints for input
    # @param index: [Integer]
    # @param hints_bag: [HintsBag]
    def add_hints_for_input(index:, hints_bag:)
      ergo_lib_transaction_hints_bag_add_hints_for_input(self.pointer, index, hints_bag.pointer)
    end

    # Get hints corresponding to index
    # @param index [Integer]
    # @return [HintsBag]
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

  # Unsigned (inputs without proofs) transaction
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

    # Parse from JSON. Supports Ergo Node/Explorer API and box values and token amount encoded as strings
    # @param json [String]
    # @return [UnsignedTransaction]
    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_unsigned_tx_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Takes ownership of an existing UnsignedTransaction Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [UnsignedTransaction]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get transaction id
    # @return [TxId]
    def get_tx_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_id(self.pointer, pointer)
      Sigma::TxId.with_raw_pointer(pointer)
    end

    # Get unsigned inputs
    # @return [UnsignedInputs]
    def get_unsigned_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_inputs(self.pointer, pointer)
      Sigma::UnsignedInputs.with_raw_pointer(pointer)
    end

    # Get data inputs
    # @return [DataInputs]
    def get_data_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_data_inputs(self.pointer, pointer)
      Sigma::DataInputs.with_raw_pointer(pointer)
    end

    # Get output candidates
    # @return [ErgoBoxCandidates]
    def get_output_candidates
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_tx_output_candidates(self.pointer, pointer)
      Sigma::ErgoBoxCandidates.with_raw_pointer(pointer)
    end

    # JSON representation as text (compatible with Ergo Node/Explorer API, numbers are encoded as numbers)
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_unsigned_tx_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # JSON representation according to EIP-12 
    # @see https://github.com/ergoplatform/eips/pull/23 EIP-12
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

  # Transaction Id
  class TxId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tx_id_delete, [:pointer], :void
    attach_function :ergo_lib_tx_id_from_str, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_id_to_str, [:pointer,:pointer], :error_pointer
  
    attr_accessor :pointer

    # Create from hex-encoded string
    # @param str [String]
    # @return [TxId]
    def self.with_string(str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_id_from_str(str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Takes ownership of an existing TxId Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [TxId]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Get the TxId as bytes represented with hex-encoded string
    # @return [String]
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

