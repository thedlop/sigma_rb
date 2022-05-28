require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class NipopowProof
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_nipopow_proof_delete, [:pointer], :void
    attach_function :ergo_lib_nipopow_proof_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_nipopow_proof_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_nipopow_proof_is_better_than, [:pointer, :pointer], ReturnBool.by_value

    attr_accessor :pointer

    # Parse NiPoPow from json
    # @param json [String]
    # @return [NipopowProof]
    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_nipopow_proof_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Implementation of the ≥ algorithm from [`KMZ17`], see Algorithm 4
    # @return [bool]
    # @see https://fc20.ifca.ai/preproceedings/74.pdf KMZ17
    def is_better_than(other_proof)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_nipopow_proof_is_better_than(self.pointer, other_proof.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    # JSON representation
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_nipopow_proof_to_json(self.pointer, s_ptr)
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
        method(:ergo_lib_nipopow_proof_delete)
      )
      obj 
    end
  end
  
  # A verifier for PoPoW proofs. During its lifetime, it processes many proofs with the aim of
  # deducing at any given point what is the best (sub)chain rooted at the specified genesis.
  class NipopowVerifier
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_nipopow_verifier_delete, [:pointer], :void
    attach_function :ergo_lib_nipopow_verifier_new, [:pointer,:pointer], :void
    attach_function :ergo_lib_nipopow_verifier_best_chain, [:pointer,:pointer], :void
    attach_function :ergo_lib_nipopow_verifier_process, [:pointer,:pointer], :error_pointer
    attr_accessor :pointer

    # Create new instance
    # @param genesis_block_id [BlockId]
    # @return [NipopowVerifier]
    def self.create(genesis_block_id)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_nipopow_verifier_new(genesis_block_id.pointer, pointer)
      init(pointer)
    end

    # Returns chain of `BlockHeader`s from the best proof.
    # @return [BlockHeaders]
    def best_chain
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_nipopow_verifier_best_chain(self.pointer, pointer)
      BlockHeaders.with_raw_pointer(pointer)
    end

    # Process given proof
    # @param proof [NipopowProof]
    def process(proof)
      error = ergo_lib_nipopow_verifier_process(self.pointer, proof.pointer)
      Util.check_error!(error)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_nipopow_verifier_delete)
      )
      obj 
    end
  end

  class PoPowHeader
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_popow_header_delete, [:pointer], :void
    attach_function :ergo_lib_popow_header_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_popow_header_get_header, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_popow_header_get_interlinks, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_po_pow_header_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    # Create from json
    # @param json [String]
    # @return [PoPowHeader]
    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_popow_header_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # JSON representation
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_popow_header_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Get header
    # @return [BlockHeader]
    def get_header
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_popow_header_get_header(self.pointer, pointer)
      Util.check_error!(error)
      BlockHeader.with_raw_pointer(pointer)
    end

    # Get interlinks
    # @return [BlockIds]
    def get_interlinks
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_popow_header_get_interlinks(self.pointer, pointer)
      Util.check_error!(error)
      BlockIds.with_raw_pointer(pointer)
    end

    # Equality check
    # @param other_header [PoPowHeader]
    # @return [bool]
    def ==(other_header)
      ergo_lib_po_pow_header_eq(self.pointer, other_header.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_popow_header_delete)
      )
      obj 
    end
  end
end
