require 'ffi'
require_relative './util.rb'

module Sigma
  class ErgoTree
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

  end
end
