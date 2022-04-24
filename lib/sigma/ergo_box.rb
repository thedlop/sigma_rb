require 'ffi'
require_relative './error.rb'

module Sigma
  class BoxId
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer

    attr_accessor :ptr

    def initialize
    end

    def self.with_string(str)
    end

    def to_s
    end

    def ==(box_id_two)
    end
  end

  class BoxValue
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer

    attr_accessor :ptr

    def initialize
    end

    def to_i
    end
  end

  class ErgoBox
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
  end
end

