require "option_parser"
require "openssl/hmac"
require "openssl"
require "crc32"
require "json"
require "digest"
require "secrets"
require "./shield/*"

module Shield::CommandParser
  case ARGV[0]?
  when "version", "--version", "-v"
    puts <<-EOF
      Version:
        Shield.cr :: Password Generator
        _Version_ :: #{VERSION} (2019.07.14)
      EOF
  when "help", "--help", "-h"
    puts <<-EOF
      Usage: shield [command] [--] [arguments]
      Command:
        version, --version, -v  Display Version Information of Shield.cr
        create, [nil, option]   Create SecureId, SecretKey by MasterKey, TitleName
        find, id, --find        Find the SecureId by TitleName
        help, --help, -h        Show this Shield: Password Generator Help
      Options:
        --iterations, -i [info]   Specify the Number of Iterations (e.g. 16384, 32768)
        --length, -l [info]       Specify the SecretKey Length (Between 10 To 99)
        --disable-symbol, -d      Generate SecretKey Without Symbol (Reduce Security)
        --by-secure-id, -s        Retrieve SecretKey by MasterKey, SecureId
        --with-pin, -p            With Create SecurePIN (SixDigit Code)
        --with-name, -n [info]    With Create UserName (e.g. 8192,12, 16384,15)
        --with-email, -e [info]   With Create Email Address (e.g. 1,12,mail.co)
      EOF
  when "find", "id", "--find"
    Builder.new(Option.new).find_id
  when "create", nil, String
    Builder.new(Option.new).create
  end
end
