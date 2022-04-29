require 'ffi'
require_relative './util.rb'

module Sigma
  class BoxId
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer

    attach_function :ergo_lib_box_id_from_str, [:string, :pointer], :error_pointer
    attach_function :ergo_lib_box_id_to_str, [:pointer, :pointer], :void
    attach_function :ergo_lib_box_id_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_id_delete, [:pointer], :void
    attach_function :ergo_lib_box_id_to_bytes, [:pointer, :pointer], :void

    attr_accessor :pointer

    def initialize(box_id_pointer)
      bid_ptr = box_id_pointer.get_pointer(0)

      self.pointer = FFI::AutoPointer.new(
        bid_ptr,
        method(:ergo_lib_box_id_delete)
      )
    end

    def self.with_string(str)
      bid_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_id_from_str(str, bid_ptr)
      Util.check_error!(error)
      self.new(bid_ptr)
    end

    def to_bytes
      b_ptr = FFI::MemoryPointer.new(:uint8, 32)
      ergo_lib_box_id_to_bytes(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, 32)
    end

    def to_s
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      ergo_lib_box_id_to_str(self.pointer, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def ==(box_id_two)
      ergo_lib_box_id_eq(self.pointer, box_id_two.pointer)
    end
  end

  class BoxValue
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer

    attr_accessor :pointer
    attach_function :ergo_lib_box_value_delete, [:pointer], :void
    attach_function :ergo_lib_box_value_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_value_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_as_i64, [:pointer], :int64
    attach_function :ergo_lib_box_value_units_per_ergo, [], :int64
    attach_function :ergo_lib_box_value_sum_of, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_safe_user_min, [:pointer], :void

    def initialize(box_value_pointer)
      bv_ptr = box_value_pointer.get_pointer(0)

      self.pointer = FFI::AutoPointer.new(
        bv_ptr,
        method(:ergo_lib_box_value_delete)
      )
    end

    def self.units_per_ergo
      ergo_lib_box_value_units_per_ergo
    end

    def self.safe_user_min
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_value_safe_user_min(bv_ptr)

      self.new(bv_ptr)
    end

    def self.sum_of(bv_one, bv_two)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_sum_of(bv_one.pointer, bv_two.pointer, bv_ptr)
      Util.check_error!(error)

      self.new(bv_ptr)
    end

    def self.with_int(int)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_from_i64(int, bv_ptr)
      Util.check_error!(error)
      self.new(bv_ptr)
    end

    def to_i
      ergo_lib_box_value_as_i64(self.pointer)
    end

    def ==(box_value_two)
      ergo_lib_box_value_eq(self.pointer, box_value_two.pointer)
    end
  end

  class ErgoBoxCandidate
  end

  class ErgoBox
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
  end
end

