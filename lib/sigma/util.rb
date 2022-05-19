require 'ffi'
require 'ffi-compiler/loader'

module Sigma
  module Util
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')

    class ErgoError < StandardError; end
    
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_error_to_string, [:error_pointer], :pointer
    attach_function :ergo_lib_delete_string, [:pointer], :void
    attach_function :ergo_lib_delete_error, [:error_pointer], :void

    def self.check_error!(error_pointer)
      return if error_pointer.null?

      c_reason_ptr = ergo_lib_error_to_string(error_pointer)
      reason = c_reason_ptr.read_string
      ergo_lib_delete_string(c_reason_ptr)
      ergo_lib_delete_error(error_pointer)
      raise ErgoError.new(reason: reason)
    end

  end
end
