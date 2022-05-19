require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class TxBuilder
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tx_builder_delete, [:pointer], :void
    attach_function :ergo_lib_tx_builder_new, [:pointer, :pointer, :uint32, :pointer, :pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_suggested_tx_fee, [:pointer], :void
    attach_function :ergo_lib_tx_builder_set_data_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_set_context_extension, [:pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_data_inputs, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_build, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_tx_builder_box_selection, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_output_candidates, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_current_height, [:pointer], :uint32
    attach_function :ergo_lib_tx_builder_fee_amount, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_change_address, [:pointer, :pointer], :void
    attach_function :ergo_lib_tx_builder_min_change_value, [:pointer, :pointer], :void


    attr_accessor :pointer

    def self.create(box_selection:, output_candidates:, current_height:, fee_amount:, change_address:, min_change_value:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_new(
        box_selection.pointer,
        output_candidates.pointer,
        current_height,
        fee_amount.pointer,
        change_address.pointer,
        min_change_value.pointer,
        pointer
      )
      init(pointer)
    end

    def self.suggested_tx_fee
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_suggested_tx_fee(pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    def set_data_inputs(data_inputs)
      ergo_lib_tx_builder_set_data_inputs(self.pointer, data_inputs.pointer)
    end

    def set_context_extension(box_id, context_extension)
      ergo_lib_tx_builder_set_context_extension(self.pointer, box_id.pointer, context_extension.pointer)
    end

    def get_data_inputs
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_data_inputs(self.pointer, pointer)
      Sigma::DataInputs.with_raw_pointer(pointer)
    end

    def build
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_tx_builder_build(self.pointer, pointer)
      Util.check_error!(error)
      Sigma::UnsignedTransaction.with_raw_pointer(pointer)
    end

    def get_box_selection
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_box_selection(self.pointer, pointer)
      Sigma::BoxSelection.with_raw_pointer(pointer)
    end

    def get_output_candidates
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_output_candidates(self.pointer, pointer)
      Sigma::ErgoBoxCandidates.with_raw_pointer(pointer)
    end

    def get_current_height
      ergo_lib_tx_builder_current_height(self.pointer)
    end

    def get_fee_amount
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_fee_amount(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    def get_change_address
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_change_address(self.pointer, pointer)
      Sigma::Address.with_raw_pointer(pointer)
    end

    def get_min_change_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tx_builder_min_change_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_tx_builder_delete)
      )
      obj 
    end
  end
end

