require 'ffi'
require_relative './util.rb'

module Sigma
  class Tokens
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    attr_accessor :pointer

    def self.with_raw_pointer(tokens_ptr)
    end
  end
end

