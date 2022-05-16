
require 'ffi'
require_relative './util.rb'

module Sigma
  class MerkleProof
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_merkle_proof_delete, [:pointer], :void
    attr_accessor :pointer

    # TODO

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
