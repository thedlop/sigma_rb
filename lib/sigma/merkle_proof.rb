
require 'ffi'
require_relative './util.rb'

module Sigma
  class MerkleProof
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_merkle_proof_delete, [:pointer], :void
    attach_function :ergo_merkle_proof_new, [:pointer, :uint, :pointer], :error_pointer
    attach_function :ergo_merkle_proof_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_merkle_proof_add_node, [:pointer, :pointer, :uint, NODE_SIDE_ENUM], :error_pointer
    attach_function :ergo_merkle_proof_valid, [:pointer, :pointer, :uint], :bool
    attach_function :ergo_merkle_proof_valid_base16, [:pointer, :pointer, :pointer], :error_pointer
    attr_accessor :pointer

    # leaf_data is an Array(Uint8)
    def self.create(leaf_data)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, leaf_data.size)
      b_ptr.write_array_of_uint8(leaf_data)
      error = ergo_merkle_proof_new(b_ptr, leaf_data.size, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_merkle_proof_from_json(json, pointer)
      init(pointer)
    end

    def add_node(hash:, side:)
      b_ptr = FFI::MemoryPointer.new(:uint8, hash.size)
      b_ptr.write_array_of_uint8(hash)
      error = ergo_merkle_proof_add_node(self.pointer, b_ptr, hash.size, side)
      Util.check_error!(error)
    end

    # Hash can be an Array(Uint8) or String
    def valid(hash)
      if hash.is_a?(Array)
        valid_with_array(hash)
      elsif hash.is_a?(String)
        valid_with_string(hash)
      else
        raise 'Invalid type for hash: #{hash.class}. It must be an Array(Uint8) or String'
      end
    end

    private def valid_with_array(hash)
      b_ptr = FFI::MemoryPointer.new(:uint8, hash.size)
      b_ptr.write_array_of_uint8(hash)
      ergo_merkle_proof_valid(self.pointer, b_ptr, b_ptr.size)
    end

    private def valid_with_string(hash)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_merkle_proof_valid_base16(self.pointer, hash, pointer)
      Util.check_error!(error)
      pointer.get_pointer(0)
    end


    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_merkle_proof_delete)
      )
      obj 
    end
  end
end
