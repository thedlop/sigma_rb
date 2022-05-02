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

  class TokenAmount
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_lib_token_amount_delete, [:pointer], :void
    attach_function :ergo_lib_token_amount_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_token_amount_as_i64, [:pointer], :int64
    attach_function :ergo_lib_token_amount_eq, [:pointer, :pointer], :bool

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.with_int(int)
      ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_token_amount_from_i64(int, ptr)
      Util.check_error!(error)

      init(ptr)
    end

    def to_i
      ergo_lib_token_amount_as_i64(self.pointer)
    end

    def ==(token_amount_two)
      ergo_lib_token_amount_eq(self.pointer, token_amount_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_token_amount_delete)
      )
      obj 
    end
  end

  class TokenId
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_lib_token_id_from_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_token_id_from_str, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_token_id_delete, [:pointer], :void
    attach_function :ergo_lib_token_id_eq, [:pointer, :pointer], :bool
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

    def ==(token_id_two)
      ergo_lib_token_id_eq(self.pointer, token_id_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_token_id_delete)
      )
      obj 
    end
  end

  class Token
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    attr_accessor :pointer

  end
end

