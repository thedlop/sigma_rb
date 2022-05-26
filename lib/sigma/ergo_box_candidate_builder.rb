require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # An ErgoBoxCandidate Builder
  class ErgoBoxCandidateBuilder
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_builder_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_build, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_builder_new, [:pointer, :pointer, :uint32, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_set_min_box_value_per_byte, [:pointer, :uint32], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_min_box_value_per_byte, [:pointer], :uint32
    attach_function :ergo_lib_ergo_box_candidate_builder_set_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_calc_box_size_bytes, [:pointer], ReturnNumUsize.by_value
    attach_function :ergo_lib_ergo_box_candidate_calc_min_box_value, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_builder_set_register_value, [:pointer, REGISTER_ID_ENUM, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_register_value, [:pointer, REGISTER_ID_ENUM, :pointer], ReturnOption.by_value
    attach_function :ergo_lib_ergo_box_candidate_builder_delete_register_value, [:pointer, REGISTER_ID_ENUM], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_mint_token, [:pointer, :pointer, :pointer, :pointer, :uint8], :void
    attach_function :ergo_lib_ergo_box_candidate_builder_add_token, [:pointer, :pointer, :pointer], :void

    attr_accessor :pointer
    # Create builder with required box parameters
    # @param box_value: [BoxValue] amount of money associated with the box
    # @param contract: [Contract] guarding contract, which should be evaluated to true in order to open(spend) this box
    # @param creation_height: [Integer] height when a transaction containing the box is created. It should not exceed height of the block, containing the transaction with this box.
    # @return [ErgoBoxCandidateBuilder]
    def self.create(box_value:, contract:, creation_height:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_builder_new(box_value.pointer, contract.pointer, creation_height, pointer)
      
      init(pointer)
    end

    # Set minimal value (per byte of the serialized box size)
    # @param min_box_value [Uint32] Unsigned 32-bit integer
    # @return [ErgoBoxCandidateBuilder] updated ErgoBoxCandidateBuilder (self)
    def set_min_box_value_per_byte(min_box_value)
      ergo_lib_ergo_box_candidate_builder_set_min_box_value_per_byte(self.pointer, min_box_value)
      self
    end

    # Get minimal value (per byte of the serialized box size)
    # @return [Integer]
    def get_min_box_value_per_byte
      ergo_lib_ergo_box_candidate_builder_min_box_value_per_byte(self.pointer)
    end

    # Set new box value
    # @param box_value [BoxValue]
    # @return [ErgoBoxCandidate] updated ErgoBoxCandidateBuilder (self)
    def set_value(box_value)
      ergo_lib_ergo_box_candidate_builder_set_value(self.pointer, box_value.pointer)
      self
    end

    # Get box value
    # @return [BoxValue]
    def get_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_builder_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    # Calulate serialized box size (in bytes)
    # @return [Integer]
    def calc_box_size_bytes
      res = ergo_lib_ergo_box_candidate_builder_calc_box_size_bytes(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    # Calculate minimal box value for the current box serialized size (in bytes)
    # @return [BoxValue]
    def calc_min_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_box_candidate_calc_min_box_value(self.pointer, pointer)
      Util.check_error!(error)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    # Set register (R4-R9) to the given value
    # @param register_id [Integer]
    # @param constant [Constant]
    # @see REGISTER_ID_ENUM
    def set_register_value(register_id, constant)
      ergo_lib_ergo_box_candidate_builder_set_register_value(self.pointer, register_id, constant.pointer)
    end

    # Gets register value or nil if empty
    # @param register_id [Integer]
    # @return [Constant, nil]
    # @see REGISTER_ID_ENUM
    def get_register_value(register_id)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_candidate_builder_register_value(self.pointer, register_id, pointer)
      Util.check_error!(res[:error]) 
      if res[:is_some]
        Sigma::Constant.with_raw_pointer(pointer)
      else
        nil
      end
    end

    # Delete register value (make register empty) for the given register id (R4-R9)
    # @param register_id [Integer]
    # @return [ErgoBoxCandidate] updated ErgoBoxCandidateBuilder (self)
    # @see REGISTER_ID_ENUM
    def delete_register_value(register_id)
      ergo_lib_ergo_box_candidate_builder_delete_register_value(self.pointer, register_id)
      self
    end
  
    # Mint token, as defined in EIP-004
    # @param token: [Token]
    # @param name: [String] Token name, will be encoded in R4
    # @param description: [String] Token description, will be encoded in R5
    # @param num_decimals: [Integer] Number of decimals, will be encoded in R6
    # @return [ErgoBoxCandidateBuilder] updated ErgoBoxCandidateBuilder (self)
    # @see https://github.com/ergoplatform/eips/blob/master/eip-0004.md EIP-004
    def mint_token(token:, name:, description:, num_decimals:)
      ergo_lib_ergo_box_candidate_builder_mint_token(
        self.pointer,
        token.pointer,
        name,
        description,
        num_decimals
      )
      self
    end

    # Add given token_id and token_amount
    # @param token_id [TokenId]
    # @param token_amount [TokenAmount]
    # @return [ErgoBoxCandidateBuilder] updated ErgoBoxCandidateBuilder (self)
    def add_token(token_id, token_amount)
      ergo_lib_ergo_box_candidate_builder_add_token(self.pointer, token_id.pointer, token_amount.pointer)
      self
    end

    # Build the box candidate
    # @return [ErgoBoxCandidate]
    def build
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_box_candidate_builder_build(self.pointer, pointer)
      Util.check_error!(error)
      ErgoBoxCandidate.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_candidate_builder_delete)
      )
      obj 
    end
  end
end
