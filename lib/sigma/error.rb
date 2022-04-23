module Sigma
  module Error
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")

    class ErgoError < StandardError; end
    
    typedef :pointer, :error_pointer
    attach_function :ergo_error_to_string, :ergo_lib_error_to_string, [:error_pointer], :pointer
    attach_function :ergo_delete_string, :ergo_lib_delete_string, [:pointer], :void
    attach_function :ergo_delete_error, :ergo_lib_delete_error, [:error_pointer], :void

    def self.check_error!(error_pointer)
      return if error_pointer.null?

      c_reason_ptr = ergo_error_to_string(error_pointer)
      reason = c_reason_ptr.read_string
      ergo_delete_string(c_reason_ptr)
      ergo_delete_error(error_pointer)
      raise ErgoError.new(reason: reason)
    end

  end
end
