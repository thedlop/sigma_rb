require 'ffi'

module Sigma
  extend FFI::Library
  typedef :pointer, :error_pointer

  # Internal FFI Struct
  # @see https://github.com/ffi/ffi/wiki/Examples#-structs FFI Struct Documentation
  class ReturnOption < FFI::Struct
    layout :is_some, :bool,
           :error, :error_pointer
  end

  # Internal FFI Struct
  # @see https://github.com/ffi/ffi/wiki/Examples#-structs FFI Struct Documentation
  class ReturnNumUsize < FFI::Struct
    layout :value, :uint,
           :error, :error_pointer
  end

  # Internal FFI Struct
  # @see https://github.com/ffi/ffi/wiki/Examples#-structs FFI Struct Documentation
  class ReturnNumI32 < FFI::Struct
    layout :value, :int32,
           :error, :error_pointer
  end

  # Internal FFI Struct
  # @see https://github.com/ffi/ffi/wiki/Examples#-structs FFI Struct Documentation
  class ReturnNumI64 < FFI::Struct
    layout :value, :int64,
           :error, :error_pointer
  end

  # Internal FFI Struct
  # @see https://github.com/ffi/ffi/wiki/Examples#-structs FFI Struct Documentation
  class ReturnBool < FFI::Struct
    layout :value, :bool,
           :error, :error_pointer
  end
end
