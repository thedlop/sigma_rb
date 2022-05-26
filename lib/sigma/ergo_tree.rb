require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # The root of ErgoScript IR. Serialized instances of this class are self sufficient and can be passed around.
  class ErgoTree
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_tree_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_tree_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_tree_from_bytes, [:pointer, :uint, :pointer], :error_pointer
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

    # Takes ownership of an existing ErgoTree Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoTree]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Decode from encoded serialized ErgoTree
    # @param bytes [Array<uint8>] Array of unsigned 8-bit integers (0-255)
    # @return [ErgoTree]
    def self.from_bytes(bytes)
      pointer = FFI::MemoryPointer.new(:pointer)
      b_ptr = FFI::MemoryPointer.new(:uint8, bytes.size)
      b_ptr.write_array_of_uint8(bytes)
      error = ergo_lib_ergo_tree_from_bytes(b_ptr, bytes.size, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Decode from a base16 encoded serialized ErgoTree
    # @param encoded_str [String]
    # @return [ErgoTree]
    def self.from_base16_encoded_string(encoded_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_tree_from_base16_bytes(encoded_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Convert to base16 encoded serialized bytes
    # @return [String]
    def to_base16_encoded_string
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_tree_to_base16_bytes(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Convert to serialized bytes
    # @return [Array<uint8>] Array of 8-bit integers (0-255)
    def to_bytes
      res = ergo_lib_ergo_tree_bytes_len(self.pointer)
      Util.check_error!(res[:error])
      bytes_length = res[:value]
      bytes_ptr = FFI::MemoryPointer.new(:uint8, bytes_length)
      error = ergo_lib_ergo_tree_to_bytes(self.pointer, bytes_ptr)
      Util.check_error!(error)
      bytes_ptr.read_array_of_uint8(bytes_length)
    end

    #  Serialized proposition expression of SigmaProp type with ConstantPlaceholder nodes instead of Constant nodes.
    # @return [Array<uint8>] Array of 8-bit integers (0-255)
    def to_template_bytes
      res = ergo_lib_ergo_tree_template_bytes_len(self.pointer)
      Util.check_error!(res[:error])
      bytes_length = res[:value]
      bytes_ptr = FFI::MemoryPointer.new(:uint8, bytes_length)
      error = ergo_lib_ergo_tree_template_bytes(self.pointer, bytes_ptr)
      Util.check_error!(error)
      bytes_ptr.read_array_of_uint8(bytes_length)
    end

    # Returns the number of constants stored in the serialized ``ErgoTree`` or throws error if the parsing of constants failed
    # @return [Integer]
    def constants_length
      res = ergo_lib_ergo_tree_constants_len(self.pointer)
      Util.check_error!(res[:error])
      res[:value]
    end

    # Return constant with given index (as stored in serialized ErgoTree) if it exists. Throws if constant parsing failed. Returns nil if no constant exists at given index
    # @param index [Integer]
    # @return [Constant, nil]
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

    # Replace the constant of the ``ErgoTree`` with the given `constant` at position `index`. Throws if no constant exists at `index`.
    # @param index: [Integer]
    # @param constant: [Constant]
    # @return [ErgoTree] ErgoTree with constant replaced (updates self)
    def replace_constant(index:, constant:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_tree_with_constant(self.pointer, index, constant.pointer, pointer)
      Util.check_error!(error)

      # Replace self.pointer with new ergo_tree pointer
      # Old pointer will be deleted when out of scope by GC
      self.class.init(pointer, obj: self)
    end

    # Equality check
    # @param ergo_tree_two [ErgoTree]
    def ==(ergo_tree_two)
      ergo_lib_ergo_tree_eq(self.pointer, ergo_tree_two.pointer)
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
