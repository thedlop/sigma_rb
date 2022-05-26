require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Inputs, that are used to enrich script context, but won't be spent by the transaction
  class DataInput
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_data_input_new, [:pointer, :pointer], :void
    attach_function :ergo_lib_data_input_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_data_input_delete, [:pointer], :void
    attr_accessor :pointer

    # Parse BoxId and create DataInput
    # @param box_id [BoxId]
    # @return [DataInput]
    def self.with_box_id(box_id)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_data_input_new(box_id.pointer, pointer) 
      init(pointer)
    end
  
    # Takes ownership of an existing DataInput Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [DataInput]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get BoxId
    # @return [BoxId]
    def get_box_id
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_data_input_new(self.pointer, pointer) 
      Sigma::BoxId.with_raw_pointer(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_data_input_delete)
      )
      obj 
    end

  end

  # An ordered collection of DataInput
  class DataInputs
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_data_inputs_new, [:pointer], :void
    attach_function :ergo_lib_data_inputs_delete, [:pointer], :void
    attach_function :ergo_lib_data_inputs_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_data_inputs_len, [:pointer], :uint8
    attach_function :ergo_lib_data_inputs_get, [:pointer, :uint8, :pointer], ReturnOption.by_value
    attr_accessor :pointer

    # Takes ownership of an existing DataInputs Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [DataInputs]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [DataInputs]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_data_inputs_new(pointer)

      init(pointer)
    end

    # Get length of DataInputs
    # @return [Integer]
    def len
      ergo_lib_data_inputs_len(self.pointer)
    end

    # Add a DataInput
    # @param data_input [DataInput]
    def add(data_input)
      ergo_lib_data_inputs_add(data_input.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @params index [Integer]
    # @return [DataInput, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_data_inputs_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::DataInput.with_raw_pointer(pointer)
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
        method(:ergo_lib_data_inputs_delete)
      )
      obj
    end
  end
end
