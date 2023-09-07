require "option_parser"

require "./handler"

module Secrets
  VERSION = "0.1.0"

  handler_operation : String | Nil = nil
  secret_key : String | Nil = nil
  secret_value : String | Nil = nil

  OptionParser.parse do |parser|
    parser.banner = "Usage: secrets [arguments]"
    parser.on("-k KEY", "--key=KEY", "Key") { |key| secret_key = key }
    parser.on("-o OPERATION", "--operation=OPERATION", "Operation to perform") { |operation| handler_operation = operation }
    parser.on("-v VALUE", "--value=VALUE", "Value") { |value| secret_value = value }
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
  end

  pp! handler_operation
  pp! secret_key
  pp! secret_value
end