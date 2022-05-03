require 'ffi'
require_relative './util.rb'

module Sigma

  class ErgoTree
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    typedef :pointer, :error_pointer

    attach_function :ergo_lib_ergo_tree_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_tree_from_base16_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_tree_to_base16_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_tree_to_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_tree_template_bytes, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_tree_bytes_len, [:pointer], ReturnNumUsize.by_value
    attach_function :ergo_lib_ergo_tree_template_bytes_len, [:pointer], ReturnNumUsize.by_value
    attach_function :ergo_lib_ergo_tree_with_constant, [:pointer, :uint8, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_tree_constants_len, [:pointer], ReturnNumUsize.by_value
    attach_function :ergo_lib_ergo_tree_get_constant, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.from_base16_encoded_string(encoded_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_tree_from_base16_bytes(encoded_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    def to_base16_encoded_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_tree_to_base16_bytes(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def to_bytes
      res = ergo_lib_ergo_tree_bytes_len(self.pointer)
      Util.check_error!(res[:error])
      bytes_length = res[:value]
      bytes_ptr = FFI::MemoryPointer.new(:uint8, bytes_length)
      error = ergo_lib_ergo_tree_to_bytes(self.pointer, bytes_ptr)
      Util.check_error!(error)
      bytes_ptr.read_array_of_uint8(bytes_length)
    end

    def to_template_bytes
      res = ergo_lib_ergo_tree_template_bytes_len(self.pointer)
      Util.check_error!(res[:error])
      bytes_length = res[:value]
      bytes_ptr = FFI::MemoryPointer.new(:uint8, bytes_length)
      error = ergo_lib_ergo_tree_template_bytes(self.pointer, bytes_ptr)
      Util.check_error!(error)
      bytes_ptr.read_array_of_uint8(bytes_length)
    end

    def constants_length
      res = ergo_lib_ergo_tree_constants_len(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    def get_constant(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_tree_get_constant(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::Constant.with_raw_pointer(pointer)
      else
        nil
      end
    end

    def replace_constant(index:, constant:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_tree_with_constant(self.pointer, index, constant.pointer, pointer)
      Util.check_error!(error)

      # Replace self.pointer with new ergo_tree pointer
      # Old pointer will be deleted when out of scope by GC
      self.class.init(pointer, obj: self)
    end

    private

    def self.init(unread_pointer, obj: nil)
      obj ||= self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_tree_delete)
      )
      obj
    end


  end
end
