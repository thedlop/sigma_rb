require 'ffi'
require_relative './util.rb'

module Sigma
  class Transaction
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tx_delete, [:pointer], :void
    attr_accessor :pointer

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # TODO
    #def to_json_eip12
    #end

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

  class UnsignedTransaction
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
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
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
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

