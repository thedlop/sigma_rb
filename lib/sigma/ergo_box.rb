require 'ffi'
require_relative './util.rb'

module Sigma
  class BoxId
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_box_id_from_str, [:string, :pointer], :error_pointer
    attach_function :ergo_lib_box_id_to_str, [:pointer, :pointer], :void
    attach_function :ergo_lib_box_id_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_id_delete, [:pointer], :void
    attach_function :ergo_lib_box_id_to_bytes, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.with_raw_pointer(bid_ptr)
      init(bid_ptr)
    end

    def self.with_string(str)
      bid_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_id_from_str(str, bid_ptr)
      Util.check_error!(error)

      init(bid_ptr)
    end

    def to_bytes
      b_ptr = FFI::MemoryPointer.new(:uint8, 32)
      ergo_lib_box_id_to_bytes(self.pointer, b_ptr)
      b_ptr.get_array_of_uint8(0, 32)
    end

    def to_s
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      ergo_lib_box_id_to_str(self.pointer, s_ptr)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

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

  class BoxValue
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_box_value_delete, [:pointer], :void
    attach_function :ergo_lib_box_value_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_box_value_from_i64, [:int64, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_as_i64, [:pointer], :int64
    attach_function :ergo_lib_box_value_units_per_ergo, [], :int64
    attach_function :ergo_lib_box_value_sum_of, [:pointer, :pointer, :pointer], :error_pointer
    attach_function :ergo_lib_box_value_safe_user_min, [:pointer], :void

    attr_accessor :pointer

    def self.with_raw_pointer(bv_pointer)
      init(bv_pointer)
    end

    def self.units_per_ergo
      ergo_lib_box_value_units_per_ergo
    end

    def self.safe_user_min
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_box_value_safe_user_min(bv_ptr)

      init(bv_ptr)
    end

    def self.sum_of(bv_one, bv_two)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_sum_of(bv_one.pointer, bv_two.pointer, bv_ptr)
      Util.check_error!(error)

      init(bv_ptr)
    end

    def self.from_i64(int)
      bv_ptr = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_box_value_from_i64(int, bv_ptr)
      Util.check_error!(error)

      init(bv_ptr)
    end

    def to_i64
      ergo_lib_box_value_as_i64(self.pointer)
    end

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

  class ErgoBoxCandidate
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidate_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_box_candidate_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_box_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_ergo_tree, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_tokens, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidate_creation_height, [:pointer], :uint32
    attach_function :ergo_lib_ergo_box_candidate_register_value, [:pointer, Sigma::REGISTER_ID_ENUM, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

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

    def get_creation_height
      ergo_lib_ergo_box_candidate_creation_height(self.pointer)
    end

    def get_tokens
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_tokens(self.pointer, pointer)
      Sigma::Tokens.with_raw_pointer(pointer)
    end

    def get_ergo_tree
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_ergo_tree(self.pointer, pointer)
      Sigma::ErgoTree.with_raw_pointer(pointer)
    end

    def get_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidate_box_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

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

  class ErgoBoxCandidates
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_candidates_new, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_candidates_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_box_candidates_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_candidates_new(pointer)

      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def len
      ergo_lib_ergo_box_candidates_len(self.pointer)
    end

    def add(ergo_box_candidate)
      ergo_lib_ergo_box_candidates_add(ergo_box_candidate.pointer, self.pointer)
    end

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

  class ErgoBox
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
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

    def self.create(box_value:,
                   creation_height:,
                   contract:,
                   tx_id:,
                   index:,
                   tokens:)

      eb_pointer = FFI::MemoryPointer.new(:pointer)
      error_pointer = ergo_lib_ergo_box_new(box_value.pointer, creation_height,
        contract.pointer, tx_id.pointer, index, tokens.pointer, eb_pointer)
      Util.check_error!(error_pointer)
      
      init(eb_pointer) 
    end

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.with_json(json_str)
      pointer = FFI::MemoryPointer.new(:pointer)
      error = ergo_lib_ergo_box_from_json(json_str, pointer)
      Util.check_error!(error)
      init(pointer)
    end

    def get_box_id
      box_id_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_id(self.pointer, box_id_ptr)
      Sigma::BoxId.with_raw_pointer(box_id_ptr)
    end

    def get_box_value
      box_value_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_value(self.pointer, box_value_ptr)
      Sigma::BoxValue.with_raw_pointer(box_value_ptr)
    end

    def get_creation_height
      ergo_lib_ergo_box_creation_height(self.pointer)
    end

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

    def get_tokens
      tokens_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_tokens(self.pointer, tokens_ptr)
      Sigma::Tokens.with_raw_pointer(tokens_ptr)
    end

    def get_ergo_tree
      ergo_tree_ptr = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_ergo_tree(self.pointer, ergo_tree_ptr)
      Sigma::ErgoTree.with_raw_pointer(ergo_tree_ptr)
    end

    def to_json
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_box_to_json(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

    def to_json_eip12
      s_ptr = FFI::MemoryPointer.new(:pointer, 1)
      error = ergo_lib_ergo_box_to_json_eip12(self.pointer, s_ptr)
      Util.check_error!(error)
      s_ptr = s_ptr.read_pointer()
      str = s_ptr.read_string().force_encoding('UTF-8')
      Util.ergo_lib_delete_string(s_ptr)
      str
    end

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

  class ErgoBoxes
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_boxes_new, [:pointer], :void
    attach_function :ergo_lib_ergo_boxes_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_boxes_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_boxes_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_boxes_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_boxes_new(pointer)

      init(pointer)
    end

    # Parameter is an ARRAY of JSON Strings
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

    def len
      ergo_lib_ergo_boxes_len(self.pointer)
    end

    def add(ergo_box)
      ergo_lib_ergo_boxes_add(ergo_box.pointer, self.pointer)
    end

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

  class ErgoBoxAssetsData
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_assets_data_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_eq, [:pointer, :pointer], :bool
    attach_function :ergo_lib_ergo_box_assets_data_new, [:pointer, :pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_value, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_tokens, [:pointer, :pointer], :void

    attr_accessor :pointer

    def self.create(box_value:, tokens:)
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_new(box_value.pointer, tokens.pointer, pointer)
      init(pointer)
    end

    def self.with_raw_pointer(pointer)
      init(pointer)
    end

    def get_box_value
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_value(self.pointer, pointer)
      Sigma::BoxValue.with_raw_pointer(pointer)
    end

    def get_box_tokens
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_tokens(self.pointer, pointer)
      Sigma::Tokens.with_raw_pointer(pointer)
    end

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

  class ErgoBoxAssetsDataList
    extend FFI::Library
    ffi_lib File.join(File.dirname(__FILE__), "../../ext/libsigma.so")
    typedef :pointer, :error_pointer
    attach_function :ergo_lib_ergo_box_assets_data_list_new, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_delete, [:pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_add, [:pointer, :pointer], :void
    attach_function :ergo_lib_ergo_box_assets_data_list_len, [:pointer], :uint8
    attach_function :ergo_lib_ergo_box_assets_data_list_get, [:pointer, :uint8, :pointer], ReturnOption.by_value

    attr_accessor :pointer

    def self.with_raw_pointer(unread_pointer)
      init(unread_pointer)
    end

    def self.create
      pointer = FFI::MemoryPointer.new(:pointer)
      ergo_lib_ergo_box_assets_data_list_new(pointer)

      init(pointer)
    end

    def len
      ergo_lib_ergo_box_assets_data_list_len(self.pointer)
    end

    def add(ergo_box_assets_data)
      ergo_lib_ergo_box_assets_data_list_add(ergo_box_assets_data.pointer, self.pointer)
    end

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

