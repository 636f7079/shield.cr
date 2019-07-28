module Shield::Parser
  class NameEmail
    include JSON::Serializable
    property userName : UserName
    property email : Email

    def initialize
      @userName = UserName.new
      @email = Email.new
    end
  end

  class UserName
    include JSON::Serializable
    property iterations : Int32
    property nonce : String
    property length : Int32

    def initialize
      @iterations = 0_i32
      @nonce = "Name"
      @length = 0_i32
    end
  end

  class Email
    include JSON::Serializable
    property iterations : Int32
    property length : Int32
    property domain : String

    def initialize
      @iterations = 0_i32
      @length = 0_i32
      @domain = String.new
    end
  end
end
