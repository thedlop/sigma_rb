require 'ffi'
require_relative './util.rb'

module Sigma
  class Transaction
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
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

