require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class TokenAmount
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_token_amount_delete, [:pointer], :void
    attach_function :ergo_lib_token_amount_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_token_amount_as_i64, [:pointer], :int64
    attach_function :ergo_lib_token_amount_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    # Takes ownership of an existing TokenAmount Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [TokenAmount]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create instance from 64-bit Integer with bounds check
    # @param int [Integer]
    # @return [TokenAmount]
    def self.with_i64(int)
      ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_token_amount_from_i64(int, ptr)
      Util.check_error!(error)

      init(ptr)
    end

    # Get value as 64-bit integer
    # @return [Integer]
    def to_i
      ergo_lib_token_amount_as_i64(self.pointer)
    end

    # Equality check
    # @param token_amount_two [TokenAmount]
    # @return [bool]
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

  # Token id (32-byte digest)
  class TokenId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_token_id_from_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_token_id_from_str, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_token_id_delete, [:pointer], :void
    attach_function :ergo_lib_token_id_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_token_id_to_str, [:pointer, :pointer], :void
    attr_accessor :pointer

    # Takes ownership of an existing TokenId Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [TokenId]
    def self.with_raw_pointer(tid_pointer)
      init(tid_pointer)
    end

    # Create token id from ergo box id (32 byte digest)
    # @param box_id [BoxId]
    # @return [TokenId]
    def self.with_box_id(box_id)
      tid_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_token_id_from_box_id(box_id.pointer, tid_ptr)

      init(tid_ptr)
    end

    # Parse token id (32 byte digest) from base16-encoded string
    # @param str [String]
    # @return [TokenId]
    def self.from_base16_encoded_string(str)
      tid_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_token_id_from_str(str, tid_ptr)
      Util.check_error!(error)

      init(tid_ptr)
    end

    # Get base16 encoded string
    # @return [String]
    def to_base16_encoded_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      ergo_lib_token_id_to_str(self.pointer, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Equality check
    # @param token_id_two [TokenId]
    # @return [bool]
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

  # Token represented with token id paired with its amount
  class Token
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_token_new, [:pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_token_get_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_token_get_amount, [:pointer, :pointer], :void
    attach_function :ergo_lib_token_delete, [:pointer], :void
    attach_function :ergo_lib_token_to_json_eip12, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_token_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    # Create a token with given id and amount
    # @param token_id: [TokenId]
    # @param token_amount: [TokenAmount]
    # @return [Token]
    def self.create(token_id:, token_amount:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_token_new(token_id.pointer, token_amount.pointer, pointer)

      init(pointer)
    end

    # Takes ownership of an existing Token Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Token]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get id
    # @return [TokenId]
    def get_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_token_get_id(self.pointer, pointer)
      Sigma::TokenId.with_raw_pointer(pointer)
    end

    # Get amount
    # @return [TokenAmount]
    def get_amount
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_token_get_amount(self.pointer, pointer)
      Sigma::TokenAmount.with_raw_pointer(pointer)
    end

    # JSON representation according to EIP-12
    # @return [String]
    # @see https://github.com/ergoplatform/eips/pull/23 EIP-12
    def to_json_eip12
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_token_to_json_eip12(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Equality check
    # @param token_two [Token]
    # @return [bool]
    def ==(token_two)
      ergo_lib_token_eq(self.pointer, token_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_token_delete)
      )
      obj
    end
  end

  # An ordered collection of Token
  class Tokens
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_tokens_delete, [:pointer], :void
    attach_function :ergo_lib_tokens_new, [:pointer], :void
    attach_function :ergo_lib_tokens_len, [:pointer], :uint8
    attach_function :ergo_lib_tokens_get, [:pointer, :uint8, :pointer], ReturnOption.by_value
    attach_function :ergo_lib_tokens_add, [:pointer, :pointer], :error_pointer
    attr_accessor :pointer

    # Create an empty collection
    # @return [Tokens]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_tokens_new(pointer)
      init(pointer)
    end

    # Takes ownership of an existing Tokens Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Tokens]
    def self.with_raw_pointer(tokens_ptr)
      init(tokens_ptr)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_tokens_len(self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [Tokens, nil]
    def get(index)
      token_pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_tokens_get(self.pointer, index, token_pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::Token.with_raw_pointer(token_pointer)
      else
        nil
      end
    end

    # Add to collection. Max capacity of ErgoBox::MAX_TOKENS_COUNT tokens. Will throw error if adding more.
    # @param token [Token]
    def add(token)
      error = ergo_lib_tokens_add(token.pointer, self.pointer)
      Util.check_error!(error)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_tokens_delete)
      )
      obj
    end
  end
end
