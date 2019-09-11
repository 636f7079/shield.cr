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
    print String.build { |io|
      io << "Enter "
      io << name << ": "
    }
  end

  def self.ask_master_key
    enter "MasterKey"
    yield Secrets.gets
  end

  def self.ask_secure_id(option : Option)
    if option.idType
      enter "Secure_Id"
      yield Utils.input
    else
      enter "TitleName"
      ip = Utils.input
      yield Utils.create_id ip
    end
  end

  def self.secure_id(option, id : String)
    unless option.idType
      final "Secure_Id", id
    end
  end

  def self.secret_key(key : String, done? : Bool)
    return final "SecretKey", key if done?
    shadow "SecretKey", key
  end
end
