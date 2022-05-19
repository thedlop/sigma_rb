require 'ffi'

module Sigma
  require_relative 'sigma/structs'
  require_relative 'sigma/enums'
  require_relative 'sigma/address'
  require_relative 'sigma/ergo_box'
  require_relative 'sigma/constant'
  require_relative 'sigma/token'
  require_relative 'sigma/ergo_tree'
  require_relative 'sigma/contract'
  require_relative 'sigma/transaction'
  require_relative 'sigma/reduced_transaction'
  require_relative 'sigma/tx_builder'
  require_relative 'sigma/data_input'
  require_relative 'sigma/box_selection'
  require_relative 'sigma/input'
  require_relative 'sigma/context_extension'
  require_relative 'sigma/ergo_box_candidate_builder'
  require_relative 'sigma/secret_key'
  require_relative 'sigma/block_header'
  require_relative 'sigma/pre_header'
  require_relative 'sigma/ergo_state_context'
  require_relative 'sigma/byte_array'
  require_relative 'sigma/wallet'
  require_relative 'sigma/merkle_proof'
  require_relative 'sigma/nipopow'

  SIGMA_RUST_VERSION = '0.16.0'
end


