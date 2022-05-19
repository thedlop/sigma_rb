require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class BlockHeader
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_header_delete, [:pointer], :void
    attach_function :ergo_lib_block_header_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_block_header_eq, [:pointer, :pointer], :bool
    attr_accessor :pointer

    def self.with_json(json)
      pointer = FFI::MemoryPointer.new(:pointer) 
      error = ergo_lib_block_header_from_json(json, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_block_id
      pointer = FFI::MemoryPointer.new(:pointer) 
      ergo_lib_block_header_id(self.pointer, pointer)
      Sigma::BlockId.with_raw_pointer(:pointer)
    end

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

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_block_headers_new(pointer)

      init(pointer)
    end

    # Parameter is an ARRAY of JSON Strings
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

    def len
      ergo_lib_block_headers_len(self.pointer)
    end

    def add(block_header)
      ergo_lib_block_headers_add(block_header.pointer, self.pointer)
    end

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

  class BlockId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_block_id_delete, [:pointer], :void
    attr_accessor :pointer

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

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_block_ids_new(pointer)

      init(pointer)
    end

    def len
      ergo_lib_block_ids_len(self.pointer)
    end

    def add(block_id)
      ergo_lib_block_ids_add(block_id.pointer, self.pointer)
    end

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

