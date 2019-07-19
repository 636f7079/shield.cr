module Shield::Render
  extend self

  def error_option(type : String)
    puts String.build { |io|
      io << "ErrorOption: "
      io << type
    } ensure abort nil
  end

  def item(name, vaule : String)
    String.build do |io|
      io << "\r" << name
      io << ": ["
      io << vaule << "]"
    end
  end

  def shadow(name, vaule : String)
    print item name, vaule
  end

  def final(name, vaule : String)
    puts item name, vaule
  end

  def enter(name : String)
    print String.build { |io|
      io << "Enter "
      io << name << ": "
    }
  end

  def ask_master_key
    enter "MasterKey"
    yield Secrets.gets
  end

  def ask_secure_id(option : Option)
    if option.idType
      enter "Secure_Id"
      yield Utilit.input
    else
      enter "TitleName"
      ip = Utilit.input
      yield Utilit.create_id ip
    end
  end

  def secure_id(option, id : String)
    unless option.idType
      final "Secure_Id", id
    end
  end

  def secret_key(key : String, done? : Bool)
    return final "SecretKey", key if done?
    shadow "SecretKey", key
  end
end
