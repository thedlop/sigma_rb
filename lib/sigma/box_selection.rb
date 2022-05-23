require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  # Selected boxes with change boxes. Instances of this class are created by SimpleBoxSelector.
  # @see SimpleBoxSelector
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

    # Create a selection to inject custom select algorithms
    # @param ergo_boxes [ErgoBoxes]
    # @param change_ergo_boxes [ErgoBoxAssetsDataList]
    # @return [BoxSelection]
    def self.create(ergo_boxes:, change_ergo_boxes:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_new(ergo_boxes.pointer, change_ergo_boxes.pointer, pointer)
      init(pointer)
    end

    # Takes ownership of an existing BoxSelection Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BoxSelection]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Selected Boxes to spend as transaction inputs
    # @return [ErgoBoxes]
    def get_boxes
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_boxes(self.pointer, pointer)
      Sigma::ErgoBoxes.with_raw_pointer(pointer)
    end

    # Selected Boxes to use as change
    # @return [ErgoBoxAssetsDataList]
    def get_change_boxes
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_selection_change(self.pointer, pointer)
      Sigma::ErgoBoxAssetsDataList.with_raw_pointer(pointer)
    end

    # Equality check between two BoxSelections
    # @param bs_two [BoxSelection]
    # @return [bool]
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

  # Naive box selector, collects inputs until target balace is reached
  class SimpleBoxSelector
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_simple_box_selector_delete, [:pointer], :void
    attach_function :ergo_lib_simple_box_selector_new, [:pointer], :void
    attach_function :ergo_lib_simple_box_selector_select, [:pointer, :pointer, :pointer, :pointer, :pointer], :error_pointer

    attr_accessor :pointer

    # Create an empty SimpleBoxSelector
    # @return [SimpleBoxSelector]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_simple_box_selector_new(pointer)
      init(pointer)
    end

    # Selects inputs to satisfy target balance and tokens
    # @param inputs [ErgoBoxes] Available inputs (returns error if empty)
    # @param target_balance [BoxValue] coins (in nanoERGs) needed
    # @param target_tokens [Tokens] amount of tokens needed
    # @return [BoxSelection] selected inputs and box assets(value + tokens) with change
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

    # Takes ownership of an existing SimpleBoxSelector Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [SimpleBoxSelector]
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

