class Shield::Option
  alias NameEmail = Parser::NameEmail
  include JSON::Serializable
  property useSymbol : Bool
  property iterations : Int32
  property idType : Bool
  property enablePin : Bool
  property length : Int32
  property nameEmail : NameEmail

  def initialize
    @nameEmail = NameEmail.new
    @length = 20_i32
    @useSymbol = true
    @idType = false
    @enablePin = false
    @iterations = 131072_i32
  end

  def parse(args : Array(String))
    OptionParser.parse args do |parser|
      parser.on("-i +", "--iterations +", "") do |item|
        item.to_i?.try do |value|
          @iterations = value if 0_i32 < value
        end
      end
      parser.on("-n +", "--with-name +", "") do |item|
        if 2_i32 == (item = item.split ",").size
          iterations, length = item
          iterations.to_i?.try do |value|
            if 0_i32 >= value
              Render.error_option "UserName::Iterations"
            end ensure nameEmail.userName.iterations = value
          end
          length.to_i?.try do |value|
            if 4_i32 > value
              Render.error_option "UserName::Length"
            end ensure nameEmail.userName.length = value
          end if 3_i32 > length.size
        end
      end
      parser.on("-e +", "--with-email +", "") do |item|
        if 3_i32 == (item = item.split ",").size
          iterations, length, domain = item
          iterations.to_i?.try do |value|
            if 0_i32 >= value
              Render.error_option "Email::Iterations"
            end ensure nameEmail.email.iterations = value
          end
          length.to_i?.try do |value|
            if 4_i32 > value
              Render.error_option "Email::Length"
            end ensure nameEmail.email.length = value
          end if 3_i32 > length.size
          nameEmail.email.domain = domain unless domain.empty?
        end
      end
      parser.on("-l +", "--length +", "") do |item|
        item.to_i?.try do |value|
          @length = value if 9_i32 < value
        end if 3_i32 > item.size
      end
      parser.on("-s", "--by-secure-id", "") do
        @idType = true
      end
      parser.on("-p", "--with-pin", "") do
        @enablePin = true
      end
      parser.on("-d", "--disable-symbol", "") do
        @useSymbol = false
      end
      parser.missing_option do |flag|
        STDERR.puts "Missing Value: #{flag}"
        STDERR.puts parser ensure abort nil
      end
      parser.invalid_option do |flag|
        STDERR.puts "Invalid Option: #{flag}"
        STDERR.puts parser ensure abort nil
      end
    end
  end
end
