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
        split = item.rpartition ","
        split.first.try do |iterations|
          iterations.to_i?.try do |_iterations|
            if 0_i32 >= _iterations
              Render.error_option "UserName::Iterations"
            end

            nameEmail.userName.iterations = _iterations
          end
        end

        split.last.try do |length|
          length.to_i?.try do |_length|
            if 3_i32 >= _length
              Render.error_option "UserName::Length"
            end

            nameEmail.userName.length = _length
          end
        end
      end
      parser.on("-e +", "--with-email +", "") do |item|
        first_split = item.rpartition ","
        first_split.first.try do |first|
          last_split = first.rpartition ","
          last_split.first.try do |iterations|
            iterations.to_i?.try do |_iterations|
              if 0_i32 >= _iterations
                Render.error_option "Email::Iterations"
              end

              nameEmail.email.iterations = _iterations
            end
          end

          last_split.last.try do |length|
            length.to_i?.try do |_length|
              if 3_i32 >= _length
                Render.error_option "Email::Length"
              end

              nameEmail.email.length = _length
            end
          end
        end

        first_split.last.try do |domain|
          unless domain.empty?
            nameEmail.email.domain = domain
          end
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
