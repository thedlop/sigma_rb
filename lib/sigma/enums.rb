require 'ffi'

module Sigma
  extend FFI::Library
  typedef :pointer, :error_pointer

  # Address type prefix
  # @see https://github.com/ffi/ffi/wiki/Enums FFI Enum Documentation
  ADDRESS_TYPE_PREFIX_ENUM = enum :address_type_prefix,
    [
      :p2pk, 1,
      :pay2sh,
      :pay2s
    ]

  # Network prefix
  # @see https://github.com/ffi/ffi/wiki/Enums FFI Enum Documentation
  NETWORK_PREFIX_ENUM = enum :network_prefix, 
    [
      :mainnet, 0,
      :testnet, 16,
    ]

  # Register id
  # @see https://github.com/ffi/ffi/wiki/Enums FFI Enum Documentation
  REGISTER_ID_ENUM = enum :non_mandatory_register_id, 
    [
      :r4, 4,
      :r5,
      :r6,
      :r7,
      :r8,
      :r9
    ]

  # Represents which side the node is on in the merkle tree
  # @see https://github.com/ffi/ffi/wiki/Enums FFI Enum Documentation
  NODE_SIDE_ENUM = enum :node_side,
    [
      :left, 0,
      :right
    ]
end
