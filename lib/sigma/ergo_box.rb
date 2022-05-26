require 'ffi'
require_relative './util.rb'
require 'ffi-compiler/loader'
require 'json'

module Sigma
  # BoxId (32-byte digest)
  class BoxId
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_box_id_from_str, [:string, :pointer], :error_pointer
    attach_function :ergo_lib_box_id_to_str, [:pointer, :pointer], :void
    attach_function :ergo_lib_box_id_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_id_delete, [:pointer], :void
    attach_function :ergo_lib_box_id_to_bytes, [:pointer, :pointer], :void

    attr_accessor :pointer

    # Takes ownership of an existing BoxId Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BoxId]
    def self.with_raw_pointer(bid_ptr)
      init(bid_ptr)
    end

    # Parse box id (32 byte digest) from base16-encoded string
    # @param str [String]
    # @return [BoxId]
    def self.with_string(str)
      bid_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_id_from_str(str, bid_ptr)
      Util.check_error!(error)

      init(bid_ptr)
    end

    # Returns byte array (32-bytes) representation
    # @return [Array<uint8, 32>]
    def to_bytes
      b_ptr = FFI::MemoryPointer.new(:uint8, 32)
      ergo_lib_box_id_to_bytes(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, 32)
    end

    # Returns base16 encoded string representation
    # @return [String]
    def to_s
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      ergo_lib_box_id_to_str(self.pointer, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Equality check of two BoxId
    # @param box_id_two [BoxId]
    # @return [bool]
    def ==(box_id_two)
      ergo_lib_box_id_eq(self.pointer, box_id_two.pointer)
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_box_id_delete)
      )
      obj 
    end
  end

  # Box value in nanoERGs with bound checks
  class BoxValue
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_box_value_delete, [:pointer], :void
    attach_function :ergo_lib_box_value_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_value_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_as_i64, [:pointer], :int64
    attach_function :ergo_lib_box_value_units_per_ergo, [], :int64
    attach_function :ergo_lib_box_value_sum_of, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_safe_user_min, [:pointer], :void

    attr_accessor :pointer

    # Takes ownership of an existing BoxValue Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [BoxValue]
    def self.with_raw_pointer(bv_pointer)
      init(bv_pointer)
    end

    # Number of units inside one ERGO (i.e. one ERG using nano ERG representation)
    def self.units_per_ergo
      ergo_lib_box_value_units_per_ergo
    end

    # Recommended (safe) minimal box value to use in case box size estimation is unavailable.
    # Allows box size upto 2777 bytes with current min box value per byte of 360 nanoERGs
    def self.safe_user_min
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_value_safe_user_min(bv_ptr)

      init(bv_ptr)
    end
    # Create a new box value which is the sum of the arguments, throwing error if value is out of bounds.
    def self.sum_of(bv_one, bv_two)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_sum_of(bv_one.pointer, bv_two.pointer, bv_ptr)
      Util.check_error!(error)

      init(bv_ptr)
    end

    # Create BoxValue from 64-bit integer
    # @param int [Integer]
    # @return [BoxValue]
    def self.from_i64(int)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_from_i64(int, bv_ptr)
      Util.check_error!(error)

      init(bv_ptr)
    end

    # Get value as 64-bit integer
    # @return [Integer]
    def to_i64
      ergo_lib_box_value_as_i64(self.pointer)
    end

    # Equality check for two BoxValues
    # @param box_value_two [BoxValue]
    # @return [bool]
    def ==(box_value_two)
      ergo_lib_box_value_eq(self.pointer, box_value_two.pointer)
    end

    private
    
    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_box_value_delete)
      )
      obj 
    end
  end

  # Contains the same fields as ``ErgoBox``, except for transaction id and index, that will be
  # calculated after full transaction formation.  Use ``ErgoBoxCandidateBuilder`` to create an instance
  class ErgoBoxCandidate
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_box_candidate_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_box_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_ergo_tree, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_tokens, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_creation_height, [:pointer], :uint32
    attach_function :ergo_lib_ergo_box_candidate_register_value, [:pointer, Sigma::REGISTER_ID_ENUM, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing ErgoBoxCandidate Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBoxCandidate]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Returns value (ErgoTree constant) stored in the register or `nil` if the register is empty
    # @param register_id [Integer]
    # @return [Constant, nil]
    # @see REGISTER_ID_ENUM
    def get_register_value(register_id)
      constant_ptr = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_candidate_register_value(self.pointer, register_id, constant_ptr)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::Constant.with_raw_pointer(constant_ptr)
      else
        nil
      end
    end

    # Get box creation height
    # @return [Integer]
    def get_creation_height
      ergo_lib_ergo_box_candidate_creation_height(self.pointer)
    end

    # Get tokens for box
    # @return [Tokens]
    def get_tokens
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_tokens(self.pointer, pointer)
      Sigma::Tokens.with_raw_pointer(pointer)
    end

    # Get ErgoTree for box
    # @return [ErgoTree]
    def get_ergo_tree
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_ergo_tree(self.pointer, pointer)
      Sigma::ErgoTree.with_raw_pointer(pointer)
    end

    # Get box value
    # @return [BoxValue]
    def get_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_box_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    # Equality check
    # @param ebc_two [ErgoBoxCandidate]
    # @return [bool]
    def ==(ebc_two)
      ergo_lib_ergo_box_candidate_eq(self.pointer, ebc_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_candidate_delete)
      )
      obj 
    end
  end

  # An ordered collection of ErgoBoxCandidate
  class ErgoBoxCandidates
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidates_new, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_box_candidates_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Create an empty collection
    # @return [ErgoBoxCandidates]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidates_new(pointer)

      init(pointer)
    end

    # Takes ownership of an existing ErgoBoxCandidates Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBoxCandidates]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_ergo_box_candidates_len(self.pointer)
    end

    # Add to collection
    # @param ergo_box_candidate [ErgoBoxCandidate]
    def add(ergo_box_candidate)
      ergo_lib_ergo_box_candidates_add(ergo_box_candidate.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [ErgoBoxCandidate, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_candidates_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::ErgoBoxCandidate.with_raw_pointer(pointer)
      else
        nil
      end
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_candidates_delete)
      )
      obj 
    end
  end

  #  Box (aka coin, or an unspent output) is a basic concept of a UTXO-based cryptocurrency.
  #  In Bitcoin, such an object is associated with some monetary value (arbitrary,
  #  but with predefined precision, so we use integer arithmetic to work with the value),
  #  and also a guarding script (aka proposition) to protect the box from unauthorized opening.
  # 
  #  In other way, a box is a state element locked by some proposition (ErgoTree).
  # 
  #  In Ergo, box is just a collection of registers, some with mandatory types and semantics,
  #  others could be used by applications in any way.
  #  We add additional fields in addition to amount and proposition~(which stored in the registers R0 and R1).
  #  Namely, register R2 contains additional tokens (a sequence of pairs (token identifier, value)).
  #  Register R3 contains height when block got included into the blockchain and also transaction
  #  identifier and box index in the transaction outputs.
  #  Registers R4-R9 are free for arbitrary usage.
  # 
  #  A transaction is unsealing a box. As a box can not be open twice, any further valid transaction
  #  can not be linked to the same box.
  # Ergo box, that is taking part in some transaction on the chain Differs with ``ErgoBoxCandidate``
  # by added transaction id and an index in the input of that transaction

  class ErgoBox
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer

    attach_function :ergo_lib_ergo_box_id, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_creation_height, [:pointer], :uint32
    attach_function :ergo_lib_ergo_box_tokens, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_ergo_tree, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_register_value, [:pointer, Sigma::REGISTER_ID_ENUM, :pointer], ReturnOption.by_value
    attach_function :ergo_lib_ergo_box_new, [:pointer,:uint32, :pointer, :pointer, :uint16, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_box_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_box_from_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_box_to_json, [:pointer, :pointer], :error_pointer
    attach_function :ergo_lib_ergo_box_to_json_eip12, [:pointer, :pointer], :error_pointer

    attr_accessor :pointer

    # Create a new box
    # @param box_value: [BoxValue] amount of money associated with box
    # @param creation_height: [Integer] height when a transaction containing the box is created
    # @param contract: [Contract] guarding contract which should be evaluted to true in order to open(spend) this box
    # @param tx_id: [TxId] transaction id in which this box was "created" (participated in outputs)
    # @param index: [Integer] index (in outputs) in the transaction
    # @return [ErgoBox]
    def self.create(box_value:,
                   creation_height:,
                   contract:,
                   tx_id:,
                   index:,
                   tokens:)

      eb_pointer = FFI::MemoryPointer.new(:pointer)
      error_pointer = ergo_lib_ergo_box_new(box_value.pointer, creation_height,
        contract.pointer, tx_id.pointer, index, tokens.pointer, eb_pointer)
      #ergo_lib_ergo_box_new(nil, 0, nil, nil, 0, nil, eb_pointer)
      #Util.check_error!(error_pointer)
      
      init(eb_pointer) 
    end

    # Takes ownership of an existing ErgoBox Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBox]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Parse and create from json. 
    # Supports Ergo Node/Explorer API and box values and token amount encoded as strings
    # @param json_str [String]
    # @return [ErgoBox]
    def self.with_json(json_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_box_from_json(json_str, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    # Get box id
    # @return [BoxId]
    def get_box_id
      box_id_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_id(self.pointer, box_id_ptr)
      Sigma::BoxId.with_raw_pointer(box_id_ptr)
    end

    # Get box value
    # @return [BoxValue]
    def get_box_value
      box_value_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_value(self.pointer, box_value_ptr)
      Sigma::BoxValue.with_raw_pointer(box_value_ptr)
    end

    # Get box creation height
    # @return [Integer]
    def get_creation_height
      ergo_lib_ergo_box_creation_height(self.pointer)
    end

    # Returns value (ErgoTree constant) stored in the register or `nil` if the register is empty
    # @param register_id [Integer]
    # @return [Constant, nil]
    # @see REGISTER_ID_ENUM
    def get_register_value(register_id)
      constant_ptr = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_register_value(self.pointer, register_id, constant_ptr)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::Constant.with_raw_pointer(constant_ptr)
      else
        nil
      end
    end

    # Get tokens for box
    # @return [Tokens]
    def get_tokens
      tokens_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_tokens(self.pointer, tokens_ptr)
      Sigma::Tokens.with_raw_pointer(tokens_ptr)
    end

    # Get ergo tree for box
    # @return [ErgoTree]
    def get_ergo_tree
      ergo_tree_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_ergo_tree(self.pointer, ergo_tree_ptr)
      Sigma::ErgoTree.with_raw_pointer(ergo_tree_ptr)
    end

    # JSON representation as text (compatible with Ergo Node/Explorer API, numbers are encoded as numbers)
    # @return [String]
    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_box_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # JSON representation according to EIP-12 
    # @see <https://github.com/ergoplatform/eips/pull/23> PR with EIP-12
    # @return [String]
    def to_json_eip12
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_box_to_json_eip12(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    # Equality check
    # @param ergo_box_two [ErgoBox]
    # @return [bool]
    def ==(ergo_box_two)
      ergo_lib_ergo_box_eq(self.pointer, ergo_box_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_delete)
      )
      obj 
    end
  end

  # An ordered collection of ErgoBox
  class ErgoBoxes
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_boxes_new, [:pointer], :void
    attach_function :ergo_lib_ergo_boxes_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_boxes_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_boxes_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_boxes_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing ErgoBoxes Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBoxes]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [ErgoBoxes]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_boxes_new(pointer)

      init(pointer)
    end

    # Create collection from ErgoBox Array JSON (Node API)
    # @param array_of_json_elements [Array<String>]
    # @note Parameter is an ARRAY of JSON Strings
    def self.from_json(array_of_json_elements)
      boxes = array_of_json_elements.map do |json|
        Sigma::ErgoBox.with_json(json)
      end
      container = create
      boxes.each do |box|
        container.add(box)
      end
      container
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_ergo_boxes_len(self.pointer)
    end

    # Add to collection
    # @param ergo_box [ErgoBox]
    def add(ergo_box)
      ergo_lib_ergo_boxes_add(ergo_box.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [ErgoBox, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_boxes_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::ErgoBox.with_raw_pointer(pointer)
      else
        nil
      end
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_boxes_delete)
      )
      obj
    end
  end

  # Pair of (value, tokens) for a box
  class ErgoBoxAssetsData
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_assets_data_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_box_assets_data_new, [:pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_tokens, [:pointer, :pointer], :void

    attr_accessor :pointer

    # Create new instance
    # @param box_value: [BoxValue]
    # @param tokens: [Tokens]
    # @return [ErgoBoxAssetsData]
    def self.create(box_value:, tokens:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_new(box_value.pointer, tokens.pointer, pointer)
      init(pointer)
    end

    # Takes ownership of an existing ErgoBoxAssetsData Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBoxAssetsData]
    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    # get box value
    # @return [BoxValue]
    def get_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    # get box tokens
    # @return [Tokens]
    def get_box_tokens
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_tokens(self.pointer, pointer)
      Sigma::Tokens.with_raw_pointer(pointer)
    end

    # Equality check
    # @param eb_asset_data_two [ErgoBoxAssetsData] 
    # @return [bool]
    def ==(eb_asset_data_two)
      ergo_lib_ergo_box_assets_data_eq(self.pointer, eb_asset_data_two.pointer)
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_assets_data_delete)
      )
      obj
    end
  end

  # An ordered collection of ErgoBoxAssetsData
  class ErgoBoxAssetsDataList
    extend FFI::Library
    ffi_lib FFI::Compiler::Loader.find('csigma')
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_assets_data_list_new, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_box_assets_data_list_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    # Takes ownership of an existing ErgoBoxAssetsDataList Pointer.
    # @note A user of sigma_rb generally does not need to call this function
    # @param pointer [FFI::MemoryPointer]
    # @return [ErgoBoxAssetsDataList]
    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    # Create an empty collection
    # @return [ErgoBoxAssetsDataList]
    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_list_new(pointer)

      init(pointer)
    end

    # Get length of collection
    # @return [Integer]
    def len
      ergo_lib_ergo_box_assets_data_list_len(self.pointer)
    end

    # Add to collection
    # @param ergo_box_assets_data [ErgoBoxAssetsData]
    def add(ergo_box_assets_data)
      ergo_lib_ergo_box_assets_data_list_add(ergo_box_assets_data.pointer, self.pointer)
    end

    # Get item at specified index or return nil if no item exists
    # @param index [Integer]
    # @return [ErgoBoxAssetsData, nil]
    def get(index)
      pointer = FFI::MemoryPointer.new(:pointer)
      res = ergo_lib_ergo_box_assets_data_list_get(self.pointer, index, pointer)
      Util.check_error!(res[:error])
      if res[:is_some]
        Sigma::ErgoBoxAssetsData.with_raw_pointer(pointer)
      else
        nil
      end
    end

    private

    def self.init(unread_pointer)
      obj = self.new
      obj_ptr = unread_pointer.get_pointer(0)

      obj.pointer = FFI::AutoPointer.new(
        obj_ptr,
        method(:ergo_lib_ergo_box_assets_data_list_delete)
      )
      obj
    end
  end
end

