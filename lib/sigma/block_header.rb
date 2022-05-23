require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Represents data available of the Block Header in a Sigma propositions.
  class BlockHeader
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_header_delete, [:pointer], :void
    attach_function :ergo_lib_block_header_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_block_header_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    # Parse BlockHeader array from json (NODE API)
    # @param json [String]
    # @return [BlockHeader]
    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer) 
      error = ergo_lib_block_header_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Takes ownership of an existing BlockHeader Pointer.  
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BlockHeader]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get BlockId of BlockHeader
    # @return [BlockId]
    def get_block_id
      pointer = FFI::MemoryPointer.new(:pointer) 
      ergo_lib_block_header_id(self.pointer, pointer)
      Sigma::BlockId.with_raw_pointer(:pointer)
    end

    # Equality check between two BlockHeaders 
    # @return [bool]
    def ==(bh_two)
      ergo_lib_block_header_eq(self.pointer, bh_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_block_header_delete)
      )
      obj
    end
  end

  # An ordered collection of BlockHeader
  class BlockHeaders
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_headers_new, [:pointer], :void
    attach_function :ergo_lib_block_headers_delete, [:pointer], :void
    attach_function :ergo_lib_block_headers_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_block_headers_len, [:pointer], :uint8
    attach_function :ergo_lib_block_headers_get, [:pointer, :uint8, :pointer], ReturnOption.by_value
    attr_accessor :pointer

    # Takes ownership of an existing BlockHeaders Pointer.  
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BlockHeaders]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [BlockHeaders]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_block_headers_new(pointer)

      init(pointer)
    end

    # Parse BlockHeaders from array of JSON
    # @param array_of_json_elements [Array<String>]
    # @return [BlockHeaders]
    def self.from_json(array_of_json_elements)
      headers = array_of_json_elements.map do |json|
        Sigma::BlockHeader.with_json(json)
      end
      container = create
      headers.each do |header|
        container.add(header)
      end
      container
    end

    # Get length of BlockHeaders
    # @return [Integer]
    def len
      ergo_lib_block_headers_len(self.pointer)
    end

    # Add a BlockHeader
    # @param block_header [BlockHeader]
    def add(block_header)
      ergo_lib_block_headers_add(block_header.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @params index [Integer]
    # @return [BlockHeader, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_block_headers_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::BlockHeader.with_raw_pointer(pointer)
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
        method(:ergo_lib_block_headers_delete)
      )
      obj
    end
  end

  # Represents the Id of a BlockHeader
  class BlockId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_id_delete, [:pointer], :void
    attr_accessor :pointer

    # Takes ownership of an existing BlockId Pointer.  
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BlockId]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_block_id_delete)
      )
      obj
    end
  end

  # An ordered collection of BlockId
  class BlockIds
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_ids_new, [:pointer], :void
    attach_function :ergo_lib_block_ids_delete, [:pointer], :void
    attach_function :ergo_lib_block_ids_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_block_ids_len, [:pointer], :uint8
    attach_function :ergo_lib_block_ids_get, [:pointer, :uint8, :pointer], ReturnOption.by_value
    attr_accessor :pointer

    # Takes ownership of an existing BlockIds Pointer.  
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BlockIds]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [BlockIds]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_block_ids_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_block_ids_len(self.pointer)
    end

    # Add to collection
    # @param block_id [BlockId]
    def add(block_id)
      ergo_lib_block_ids_add(block_id.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [BlockId, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_block_ids_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::BlockId.with_raw_pointer(pointer)
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
        method(:ergo_lib_block_ids_delete)
      )
      obj
    end
  end
end

