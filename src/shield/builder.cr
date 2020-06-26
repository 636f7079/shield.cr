class Shield::Builder
  getter option : Option
  property rsaSlider : Slider
  property pbkdfSlider : Slider

  def initialize(@option : Option)
    @rsaSlider = Slider.new 0_i32, 0_i32, -1_i32
    @pbkdfSlider = Slider.new 0_i32, 0_i32, 1_i32
    @option.parse ARGV
  end

  def reset_slider
    @rsaSlider = Slider.new 0_i32, 0_i32, -1_i32
    @pbkdfSlider = Slider.new 0_i32, 0_i32, 1_i32
  end

  def render_create
    Render.ask_master_key do |master_key|
      Render.ask_secure_id option do |secure_id|
        Render.secure_id option, secure_id
        create_key(master_key, secure_id) do |done?, data|
          Render.secret_key data, done?
          create_pin data do |pin|
            Render.final "_PinCode_", pin
          end if done?
          create_name(data, secure_id) do |done?, name|
            return Render.final "_UserName", name if done?
            Render.shadow "_UserName", name
          end if done?
          create_email(data, secure_id) do |done?, email|
            return Render.final "__Email__", email if done?
            Render.shadow "__Email__", email
          end if done?
        end
      end
    end
  end

  def find_id
    Render.ask_secure_id option do |id|
      Render.secure_id option, id
    end
  end

  {% for item in ["name", "email"] %}
  def iterative_{{item.id}}(key, id : String)
    {% if "name" == item.id %}
      name_email = option.nameEmail.userName.dup
      mixed = String.build do |io| 
        io << name_email.nonce << ":" << key 
      end
    {% else %}
      name_email = option.nameEmail.email.dup
      mixed = String.build do |io|
        io << name_email.domain << ":" << key
      end
    {% end %}
    option.iterations = name_email.iterations
    option.useSymbol = false ensure reset_slider
    option.length = name_email.length
    create_key(mixed, id) do |done?, data|
      full_name = data.downcase.chars
      start = Character.user_name full_name[0_i32..3_i32]
      full_name.delete_at 0_i32..3_i32
      yield done?, String.build do |io|
        io << start.reverse << full_name.join
      end
    end
  end
  {% end %}

  def create_pin(key : String)
    if option.enablePin
      create_pin!(key) { |data| yield data }
    end
  end

  def create_pin!(key : String)
    crc32 = Digest::CRC32.checksum(key).to_s
    l, r = Utils.center crc32.size, 6_i32
    yield crc32[l..r]
  end

  def create_email(key, id : String)
    if 0_i32 < option.nameEmail.email.length
      create_email!(key, id) do |done?, data|
        yield done?, data
      end
    end
  end

  def create_email!(key, id : String)
    iterative_email(key, id) do |done?, name|
      yield done?, String.build do |io|
        io << name << "@"
        io << option.nameEmail.email.domain
      end
    end
  end

  def create_name(key, id : String)
    if 0_i32 < option.nameEmail.userName.length
      create_name!(key, id) do |done?, data|
        yield done?, data
      end
    end
  end

  def create_name!(key, id : String)
    iterative_name(key, id) do |done?, name|
      yield done?, name
    end
  end

  def slide(slider, hash, length)
    case [slider.left, slider.right]
    when [0_i32, 0_i32] of Int32
      l, r = Utils.center hash, length
      slider.left = l
      slider.right = r
    when [slider.left, hash - 1_i32]
      slider.action = -1_i32
      slider.left += slider.action
      slider.right += slider.action
    when [0_i32, slider.right]
      slider.action = 1_i32
      slider.left += slider.action
      slider.right += slider.action
    else
      slider.left += slider.action
      slider.right += slider.action
    end
  end

  def create_key(key : String, id : String)
    option.iterations.times do |time|
      _rsa_ = String.build { |io| io << Utils.digest(key) << ":" << id }
      slide rsaSlider, _rsa_.size, (_rsa_.size / 2_i32).to_i32
      _hmac = String.build do |io|
        io << id << ":" << Utils.hmac _rsa_, Utils.crc32(_rsa_).reverse
      end
      pbkdf = OpenSSL::PKCS5.pbkdf2_hmac(secret: _hmac, salt: _rsa_,
        iterations: 2 ** 5, algorithm: OpenSSL::Algorithm::SHA512).hexstring
      slide pbkdfSlider, pbkdf.size, option.length
      key = Character.hash_obfuscate pbkdf[pbkdfSlider.left..pbkdfSlider.right], option
      if option.iterations == time + 1_i32
        return yield true, Character.strict_obfuscate key, option
      else
        yield false, key
      end
    end
  end
end
