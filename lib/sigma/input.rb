require 'ffi'
require_relative './util.rb'

module Sigma
  class Input
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attr_accessor :pointer
    attach_function :ergo_lib_input_delete, [:pointer], :void
    attach_function :ergo_lib_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_input_spending_proof, [:pointer, :pointer], :void

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_input_box_id(self.pointer, pointer)
      Sigma::BoxId.with_raw_pointer(pointer)
    end

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

  class Inputs
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_inputs_new, [:pointer], :void
    attach_function :ergo_lib_inputs_delete, [:pointer], :void
    attach_function :ergo_lib_inputs_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_inputs_len, [:pointer], :uint8
    attach_function :ergo_lib_inputs_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_inputs_new(pointer)

      init(pointer)
    end

    def len
      ergo_lib_inputs_len(self.pointer)
    end

    def add(input)
      ergo_lib_inputs_add(input.pointer, self.pointer)
    end

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

  class ProverResult
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_prover_result_delete, [:pointer], :void
    attach_function :ergo_lib_prover_result_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_prover_result_context_extension, [:pointer, :pointer], :void
    attach_function :ergo_lib_prover_result_proof, [:pointer, :pointer], :void
    attach_function :ergo_lib_prover_result_proof_len, [:pointer], :uint
    attr_accessor :pointer

    def to_bytes
      proof_len = ergo_lib_prover_result_proof_len(self.pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, proof_len)
      ergo_lib_prover_result_proof(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, proof_len) 
    end

    def get_context_extension
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_prover_result_context_extension(self.pointer, pointer)
      Sigma::ContextExtension.with_raw_pointer(pointer)
    end

    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_prover_result_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

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

  class UnsignedInput
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_unsigned_input_delete, [:pointer], :void
    attach_function :ergo_lib_unsigned_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_input_context_extension, [:pointer, :pointer], :void

    attr_accessor :pointer
    
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_input_box_id(self.pointer, pointer)
      Sigma::BoxId.with_raw_pointer(pointer)
    end

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

  class UnsignedInputs
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_unsigned_inputs_new, [:pointer], :void
    attach_function :ergo_lib_unsigned_inputs_delete, [:pointer], :void
    attach_function :ergo_lib_unsigned_inputs_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_unsigned_inputs_len, [:pointer], :uint8
    attach_function :ergo_lib_unsigned_inputs_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_unsigned_inputs_new(pointer)

      init(pointer)
    end

    def len
      ergo_lib_unsigned_inputs_len(self.pointer)
    end

    def add(unsigned_input)
      ergo_lib_unsigned_inputs_add(unsigned_input.pointer, self.pointer)
    end

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
