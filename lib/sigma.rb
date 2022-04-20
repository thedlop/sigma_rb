require 'ffi'
module Sigma
  extend FFI::Library
  ffi_lib File.join(File.dirname(__FILE__), "../ext/libsigma.so")

  attach_function :constant_from_base_16, :ergo_lib_constant_from_base16, [:string, :pointer], :pointer
end

puts Sigma.constant_from_base_16('6732a346dd60f45215099140b98fbd31d9d2d48a7e1d736fd023e4dfb3833fff', nil)
