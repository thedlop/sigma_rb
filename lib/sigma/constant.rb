require 'ffi'
module Sigma
  class Constant
    # FFI::Pointer
    attr_accessible :ptr

    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    attach_function :constant_eq, :ergo_lib_constant_eq, [:pointer, :pointer], :boolean
    attach_function :constant_from_base_16, :ergo_lib_constant_from_base16, [:string, :pointer], :pointer
    attach_function :constant_from_i32, :ergo_lib_constant_from_i32, [:int32], :pointer
    attach_function :constant_from_i64, :ergo_lib_constant_from_i64, [:int64], :pointer

    def ==(constant_one, constant_two)
      constant_eq(constant_one.ptr, constant_two.ptr)
    end
  end
end
