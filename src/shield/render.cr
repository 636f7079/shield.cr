module Shield::Render
  def self.error_option(type : String)
    puts String.build { |io|
      io << "ErrorOption: "
      io << type
    } ensure abort nil
  end

  def self.item(name, vaule : String)
    String.build do |io|
      io << "\r" << name
      io << ": ["
      io << vaule << "]"
    end
  end

  def self.shadow(name, vaule : String)
    print item name, vaule
  end

  def self.final(name, vaule : String)
    puts item name, vaule
  end

  def self.enter(name : String)
    String.build do |io|
      io << "Enter "
      io << name << ": "
    end
  end

  def self.ask_master_key
    yield Secret.gets enter "MasterKey"
  end

  def self.ask_secure_id(option : Option)
    return yield Utils.input enter "Secure_Id" if option.idType

    input = Utils.input enter "TitleName"
    yield Utils.create_id input
  end

  def self.secure_id(option, id : String)
    return if option.idType
    final "Secure_Id", id
  end

  def self.secret_key(key : String, done? : Bool)
    return final "SecretKey", key if done?
    shadow "SecretKey", key
  end
end
