require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  class BoxSelection
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_box_selection_delete, [:pointer], :void
    attach_function :ergo_lib_box_selection_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_selection_new, [:pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_box_selection_boxes, [:pointer, :pointer], :void
    attach_function :ergo_lib_box_selection_change, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.create(ergo_boxes:, change_ergo_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_new(ergo_boxes.pointer, change_ergo_boxes.pointer, pointer)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_boxes
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_boxes(self.pointer, pointer)
      Sigma::ErgoBoxes.with_raw_pointer(pointer)
    end

    def get_change_boxes
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_change(self.pointer, pointer)
      Sigma::ErgoBoxAssetsDataList.with_raw_pointer(pointer)
    end

    def ==(bs_two)
      ergo_lib_box_selection_eq(self.pointer, bs_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_box_selection_delete)
      )
      obj 
    end
  end

  class SimpleBoxSelector
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_simple_box_selector_delete, [:pointer], :void
    attach_function :ergo_lib_simple_box_selector_new, [:pointer], :void
    attach_function :ergo_lib_simple_box_selector_select, [:pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer

    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_simple_box_selector_new(pointer)
      init(pointer)
    end

    def select(inputs:, target_balance:, target_tokens:)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_simple_box_selector_select(
        self.pointer,
        inputs.pointer,
        target_balance.pointer,
        target_tokens.pointer,
        pointer
      )
      Util.check_error!(error)
      Sigma::BoxSelection.with_raw_pointer(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_simple_box_selector_delete)
      )
      obj 
    end
  end
end

