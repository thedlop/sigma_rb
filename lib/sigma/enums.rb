require 'ffi'

module Sigma
  extend FFI::Library
  typedef :pointer, :error_pointer

  ADDRESS_TYPE_PREFIX_ENUM = enum :address_type_prefix,
    [
      :p2pk, 1,
      :pay2sh,
      :pay2s
    ]

  NETWORK_PREFIX_ENUM = enum :network_prefix, 
    [
      :mainnet, 0,
      :testnet, 16,
    ]

  REGISTER_ID_ENUM = enum :non_mandatory_register_id, 
    [
      :r4, 4,
      :r5,
      :r6,
      :r7,
      :r8,
      :r9
    ]

end
