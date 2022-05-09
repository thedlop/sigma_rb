require 'ffi'
require_relative './util.rb'

module Sigma
  class ErgoBoxCandidateBuilder
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_builder_delete, [:pointer], :void
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

    def self.create(box_value:, contract:, creation_height:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_builder_new(box_value.pointer, contract.pointer, creation_height, pointer)
      
      init(pointer)
    end

    def set_min_box_value_per_byte(min_box_value)
      ergo_lib_ergo_box_candidate_builder_set_min_box_value_per_byte(self.pointer, min_box_value)
      self
    end

    def get_min_box_value_per_byte
      ergo_lib_ergo_box_candidate_builder_min_box_value_per_byte(self.pointer)
    end

    def set_value(box_value)
      ergo_lib_ergo_box_candidate_builder_set_value(self.pointer, box_value.pointer)
      self
    end

    def get_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_builder_set_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    def calc_box_size_bytes
      res = ergo_lib_ergo_box_candidate_builder_calc_box_size_bytes(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    # TODO Requires ErgoBoxCandidate
    def calc_min_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_box_candidate_calc_min_box_value(self.pointer, pointer)
      Util.check_error!(error)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    def set_register_value(register_id, constant)
      ergo_lib_ergo_box_candidate_builder_set_register_value(self.pointer, register_id, constant.pointer)
    end

    def get_register_value(register_id)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_candidate_builder_register_value(self.pointer, register_id, constant.pointer)
      Util.check_error!(res[:error]) 
      if res[:is_some]
        Sigma::Constant.with_raw_pointer(pointer)
      else
        nil
      end
    end

    def delete_register_value(register_id)
      ergo_lib_ergo_box_candidate_builder_delete_register_value(self.pointer, register_id)
      self
    end
  
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

    def add_token(token_id, token_amount)
      ergo_lib_ergo_box_candidate_builder_add_token(self.pointer, token_id.pointer, token_amount.pointer)
      self
    end

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
