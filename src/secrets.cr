require "option_parser"

require "./handler"

module Secrets
  VERSION = "0.1.0"

  password : String | Nil = nil
  operation : String | Nil = nil
  target : Path = Path[Dir.current, "secrets"]
  keys = [] of String
  secret_value : String | Nil = nil

  OptionParser.parse do |parser|
    parser.banner = "Usage: secrets -p password subcommand [arguments]"
    parser.on("get-all-secrets", "Get all secrets") do
      operation = "get-all-secrets"
    end
    parser.on("get-keys", "Get keys") do
      operation = "get-keys"
    end
    parser.on("get-secrets", "Get some secrets") do
      operation = "get-secrets"
      parser.unknown_args do |args|
        keys += args
      end
    end
    parser.on("remove-secrets", "Remove some secrets") do
      operation = "remove-secrets"
      parser.unknown_args do |args|
        keys += args
      end
    end
    parser.on("set-secrets", "Set some secrets") do
      operation = "set-secrets"
      parser.unknown_args do |args|
        keys += args
      end
    end
    parser.on("-h", "--help", "Show this help") do
      puts parser
      exit
    end
    parser.on("-o OUTFILE", "--outfile=OUTFILE", "Which file to write secrets to (default 'secrets')") do |outfile|
      target = Path.new(outfile)
    end
    parser.on("-p PASSWORD", "--password=PASSWORD", "Password") do |pwd|
      password = pwd
    end
    parser.invalid_option do |flag|
      STDERR.puts "ERROR: #{flag} is not a valid option."
      STDERR.puts parser
      exit(1)
    end
    parser.missing_option do |flag|
      STDERR.puts "ERROR: #{flag} is missing."
      STDERR.puts parser
      exit(1)
    end
  end

  if (pwd = password).nil?
    STDERR.puts "Password required for all operations!"
    exit(1)
  end

  handler = Handler.new(pwd, target)

  case operation
  when "get-all-secrets"
    handler.get_all_secrets.each do |secret|
      STDOUT.puts "Secret for \"#{secret.first}\" is \"#{secret.last}\"."
    end
  when "get-keys"
    string_keys = handler.get_keys.map { |key| "\"#{key}\"" }.join(", ")
    STDOUT.puts "Available keys: #{string_keys}"
  when "get-secrets"
    handler.get_secrets(keys).each do |secret|
      STDOUT.puts "Secret for \"#{secret.first}\" is \"#{secret.last}\"."
    end
  when "remove-secrets"
    handler.remove_secrets(keys)
    keys.each do |key|
      STDOUT.puts "Secret for \"#{key}\" removed."
    end
  when "set-secrets"
    pairs =
      keys
      .map { |key| key.split("=") }
      .select { |values| values.size == 2 }
      .map { |values| {values.first.strip(' '), values.last.strip(' ')} }
    handler.set_secrets(pairs)
    pairs.each do |pair|
      puts "Set secret for \"#{pair.first}\"."
    end
  else
    STDERR.puts "Invalid operation #{operation}"
    exit(1)
  end
end