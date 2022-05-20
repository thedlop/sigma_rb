require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'json'

require_relative '../../lib/sigma.rb'
require_relative '../test_utils.rb'

include Sigma

class Sigma::MerkleProof::Test < Test::Unit::TestCase
  def test_block_proof
    json = {
      leafData: "563b34b96e65788d767a10b0c2ce4a9ef5dcb9f7f7919781624870d56506dc5b",
      levels: [
          ["274d105b42c2da3e03519865470ccef5072d389b153535ca7192fef4abf3b3ed", 0],
          ["c1887cee0c42318ac04dfa93b8ef6b40c2b53a83b0e111f91a16b0842166e76e", 0],
          ["58be076cd9ef596a739ec551cbb6b467b95044c05a80a66a7f256d4ebafd787f", 0]]
    }.to_json
    merkle_proof = MerkleProof.with_json(json)
    root = "250063ac1cec3bf56f727f644f49b70515616afa6009857a29b1fe298441e69a"
    assert(merkle_proof.valid(root))
  end

  def test_miner_proof
    json = {
      leafData: "642c15c62553edd8fd9af9a6f754f3c7a6c03faacd0c9b9d5b7d11052c6c6fe8",
      levels: [["39b79af823a92aa72ced2c6d9e7f7f4687de5b5af7fab0ad205d3e54bda3f3ae",1]]
    }.to_json
    merkle_proof = MerkleProof.with_json(json)
    root = "74c851610658a40f5ae74aa3a4babd5751bd827a6ccc1fe069468ef487cb90a8"
    assert(merkle_proof.valid(root))
  end
end
