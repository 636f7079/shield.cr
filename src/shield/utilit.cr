module Shield::Utilit
  extend self

  def center(all, limit : Int32)
    l = (all - limit) / 2_i32
    r = all - l
    i = r - l + 1_i32 - limit
    r -= 1_i32 if i < 2_i32
    r -= 2_i32 if i >= 2_i32
    [Int32.new(l), Int32.new(r)]
  end

  def uuid : Array(Regex | String)
    [/(.{8})(.{4})(.{4})(.{4})(.{12})/,
     "\\1-\\2-\\3-\\4-\\5"]
  end

  def create_id(title : String) : String
    hash = Utilit.digest title, "sha384"
    l, r = Utilit.center hash.size, 32_i32
    hash[l..r].gsub(uuid.first,
      uuid.last.as String).upcase
  end

  def crc32(text : String) : String
    CRC32.checksum(text).to_s 16_i32
  end

  def digest(text, algorithm = "sha512WithRSAEncryption")
    OpenSSL::Digest.new(algorithm).update(text).to_s
  end

  def hmac(data, key, algorithm = OpenSSL::Algorithm::SHA512)
    OpenSSL::HMAC.hexdigest algorithm, key, data
  end

  def input : String
    STDIN.gets.to_s.chomp.rstrip
  end
end
