require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Signed inputs used in signed transactions
  class Input
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attr_accessor :pointer
    attach_function :ergo_lib_input_delete, [:pointer], :void
    attach_function :ergo_lib_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_input_spending_proof, [:pointer, :pointer], :void

    # Takes ownership of an existing Input Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Input]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get box id
    # @return [BoxId]
    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_input_box_id(self.pointer, pointer)
      Sigma::BoxId.with_raw_pointer(pointer)
    end

    # Get spending proof
    # @return [ProverResult]
    def get_spending_proof
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_input_spending_proof(self.pointer, pointer)
      Sigma::ProverResult.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_input_delete)
      )
      obj
    end
  end

  # An ordered collectino of Input
  class Inputs
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_inputs_new, [:pointer], :void
    attach_function :ergo_lib_inputs_delete, [:pointer], :void
    attach_function :ergo_lib_inputs_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_inputs_len, [:pointer], :uint8
    attach_function :ergo_lib_inputs_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing Inputs Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Inputs]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [Inputs]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_inputs_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_inputs_len(self.pointer)
    end

    # Add to collection
    # @param input [Input]
    def add(input)
      ergo_lib_inputs_add(input.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @params index [Integer]
    # @return [Input, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_inputs_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::Input.with_raw_pointer(pointer)
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
        method(:ergo_lib_inputs_delete)
      )
      obj
    end
  end

  # Proof of correctness for transaction spending
  class ProverResult
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_prover_result_delete, [:pointer], :void
    attach_function :ergo_lib_prover_result_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_prover_result_context_extension, [:pointer, :pointer], :void
    attach_function :ergo_lib_prover_result_proof, [:pointer, :pointer], :void
    attach_function :ergo_lib_prover_result_proof_len, [:pointer], :uint
    attr_accessor :pointer

    # Get proof bytes
    # @return [Array<uint8>] Array of 8-bit integers [0-255]
    def to_bytes
      proof_len = ergo_lib_prover_result_proof_len(self.pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, proof_len)
      ergo_lib_prover_result_proof(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, proof_len) 
    end

    # Get context extension
    # @return [ContextExtension]
    def get_context_extension
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_prover_result_context_extension(self.pointer, pointer)
      Sigma::ContextExtension.with_raw_pointer(pointer)
    end

    # JSON representation as text (compatible with Ergo Node/Explorer API, numbers are encoded as numbers)
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_prover_result_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Takes ownership of an existing ProverResult Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ProverResult]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_prover_result_delete)
      )
      obj
    end
  end

  # Unsigned inputs used in constructing unsigned transactions
  class UnsignedInput
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_unsigned_input_delete, [:pointer], :void
    attach_function :ergo_lib_unsigned_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_input_context_extension, [:pointer, :pointer], :void

    attr_accessor :pointer
    
    # Takes ownership of an existing UnsignedInput Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [UnsignedInput]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get box id
    # @return [BoxId]
    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_input_box_id(self.pointer, pointer)
      Sigma::BoxId.with_raw_pointer(pointer)
    end

    # Get context extension
    # @return [ContextExension]
    def get_context_extension
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_input_context_extension(self.pointer, pointer)
      Sigma::ContextExtension.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_unsigned_input_delete)
      )
      obj
    end
  end

  # An ordered collection of UnsignedInput
  class UnsignedInputs
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_unsigned_inputs_new, [:pointer], :void
    attach_function :ergo_lib_unsigned_inputs_delete, [:pointer], :void
    attach_function :ergo_lib_unsigned_inputs_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_inputs_len, [:pointer], :uint8
    attach_function :ergo_lib_unsigned_inputs_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing UnsignedInputs Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [UnsignedInputs]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [UnsignedInputs]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_inputs_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_unsigned_inputs_len(self.pointer)
    end

    # Add to collection
    # @param unsigned_input [UnsignedInput]
    def add(unsigned_input)
      ergo_lib_unsigned_inputs_add(unsigned_input.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @params index [Integer]
    # @return [UnsignedInput, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_unsigned_inputs_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::UnsignedInput.with_raw_pointer(pointer)
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
        method(:ergo_lib_unsigned_inputs_delete)
      )
      obj
    end
  end
end
