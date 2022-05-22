require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'

module Sigma
  #
  # An address is a short string corresponding to some script used to protect a box. Unlike (string-encoded) binary
  # representation of a script, an address has some useful characteristics:
  #
  # - Integrity of an address could be checked., as it is incorporating a checksum.
  # - A prefix of address is showing network and an address type.
  # - An address is using an encoding (namely, Base58) which is avoiding similarly l0Oking characters, friendly to
  # double-clicking and line-breaking in emails.
  #
  #
  #
  # An address is encoding network type, address type, checksum, and enough information to watch for a particular scripts.
  #
  # Possible network types are:  
  # Mainnet - 0x00  
  # Testnet - 0x10  
  #
  # For an address type, we form content bytes as follows:
  #
  # P2PK - serialized (compressed) public key  
  # P2SH - first 192 bits of the Blake2b256 hash of serialized script bytes  
  # P2S  - serialized script  
  #                                                                                                                                                             
  # Address examples for testnet:  
  # 3   - P2PK (3WvsT2Gm4EpsM9Pg18PdY6XyhNNMqXDsvJTbbf6ihLvAmSb7u5RN)  
  # ?   - P2SH (rbcrmKEYduUvADj9Ts3dSVSG27h54pgrq5fPuwB)  
  # ?   - P2S (Ms7smJwLGbUAjuWQ)  
  #
  # for mainnet:  
  #
  # 9  - P2PK (9fRAWhdxEsTcdb8PhGNrZfwqa65zfkuYHAMmkQLcic1gdLSV5vA)  
  # ?  - P2SH (8UApt8czfFVuTgQmMwtsRBZ4nfWquNiSwCWUjMg)  
  # ?  - P2S (4MQyML64GnzMxZgm, BxKBaHkvrTvLZrDcZjcsxsF7aSsrN73ijeFZXtbj4CXZHHcvBtqSxQ)  
  #
  #
  # Prefix byte = network type + address type  
  #
  # checksum = blake2b256(prefix byte ++ content bytes)  
  #
  # address = prefix byte ++ content bytes ++ checksum
  #
  #
  class Address
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_address_from_testnet, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_from_mainnet, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_from_base58, [:pointer,:pointer], :error_pointer
    attach_function :ergo_lib_address_to_base58, [:pointer, Sigma::NETWORK_PREFIX_ENUM, :pointer], :void
    attach_function :ergo_lib_address_delete, [:pointer], :void
    attach_function :ergo_lib_address_type_prefix, [:pointer], :uint8
    attr_accessor :pointer

    # Takes ownership of an existing Address Pointer.  
    # Note: A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [Address]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Decode (base58) testnet address from string and create Address, checking that address is from the testnet
    # @param address_str [String]
    # @return [Address]
    def self.with_testnet_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_testnet(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Decode (base58) mainnet address from string and create Address, checking that address is from the testnet
    # @param address_str [String]
    # @return [Address]
    def self.with_mainnet_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_mainnet(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Decode (base58) address from string and create Address, no checking of network prefix
    # @param address_str [String]
    # @return [Address]
    def self.with_base58_address(address_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_address_from_base58(address_str, pointer)
      Util.check_error!(error)

      init(pointer)
    end

    # Encode Address to a base58 string
    # @see Sigma::NETWORK_PREFIX_ENUM
    # @param network_prefix [Integer]
    # @return [String]
    def to_base58(network_prefix)
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_address_to_base58(self.pointer, network_prefix, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Get the Network Prefix type of Address
    # @see Sigma::NETWORK_PREFIX_ENUM
    # @return [Integer]
    def type_prefix
      ergo_lib_address_type_prefix(self.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_address_delete)
      )
      obj 
    end
  end
end
