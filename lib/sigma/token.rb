require 'ffi'
require_relative './util.rb'

module Sigma
  class Tokens
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    attr_accessor :pointer

    def self.with_raw_pointer(tokens_ptr)
    end
  end

  class TokenId
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_lib_token_id_from_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_token_id_from_str, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_token_id_delete, [:pointer], :void
    attach_function :ergo_lib_token_id_to_str, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.with_raw_pointer(tid_pointer)
      init(tid_pointer)
    end

    def self.with_box_id(box_id)
      tid_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_token_id_from_box_id(box_id.pointer, tid_ptr)

      init(tid_ptr)
    end

    def self.with_string(str)
      tid_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_token_id_from_str(str, tid_ptr)
      Util.check_error!(error)

      init(tid_ptr)
    end

    def to_base16_encoded_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      ergo_lib_token_id_to_str(self.pointer, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    private

    def self.init(token_id_pointer)
      tid = self.new
      tid_ptr = token_id_pointer.get_pointer(0)

      tid.pointer = FFI::AutoPointer.new(
        tid_ptr,
        method(:ergo_lib_token_id_delete)
      )
      tid
    end
  end

  class Token
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    attr_accessor :pointer

  end
end

