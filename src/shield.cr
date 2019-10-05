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
        _Version_ :: #{VERSION} (2019.10.06)
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
        --length, -l [info]       Specify the Length of SecretKey (Between 10 To 99)
        --disable-symbol, -d      Generate SecretKey without Symbol (Reduce Security)
        --by-secure-id, -s        Retrieve SecretKey by MasterKey, SecureId
        --pin, -p                 Create SecurePIN (Six-Digit PIN Code)
        --user-name               Create UserName (e.g. 16384,12, 32768,15)
        -n [info]                 Create UserName (e.g. 16384,12, 32768,15)
        --email, -e [info]        Create Email Address (e.g. 16384,12,example.com)
      EOF
  when "find", "id", "--find"
    Builder.new(Option.new).find_id
  when "create", nil, String
    Builder.new(Option.new).render_create
  end
end
