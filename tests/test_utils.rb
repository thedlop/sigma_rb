module TestUtils 
  def self.base16_string_to_bytes(str)
    bytes = [] 
    str.split(//).each_slice(2) do |p|
      bytes << p.join.to_i(16)
    end
    bytes
  end
end
