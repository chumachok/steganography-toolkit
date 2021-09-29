require "optparse"
require_relative "stego_toolkit/core"

PROGNAME = File.basename(__FILE__)

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "usage: ruby #{PROGNAME} --medium <medium> --data <data> --password <password>"

  opts.on("-m", "--medium medium", "specify cover medium") do |medium|
    options[:cover_medium] = medium
  end

  opts.on("-d", "--data data", "specify hidden data") do |data|
    options[:data_path] = data
  end

  opts.on("-p", "--password password", "specify password") do |password|
    options[:password] = password
  end

  opts.on("--embed", "embed data") do |embed|
    options[:embed] = embed
  end

  opts.on("--extract", "extract data") do |extract|
    options[:extract] = extract
  end

  opts.on("-h", "--help", "print help") do
    $stdout.puts opts
    exit(0)
  end
end

begin
  option_parser.parse!
rescue OptionParser::InvalidOption => e
  $stderr.puts option_parser.banner
  exit(1)
end

unless options[:embed] ^ options[:extract]
  $stderr.puts "either the --embed or --extract flags must be present"
  exit(1)
end

if options[:embed]
  StegoToolkit::Core.new.embed(cover_medium: options[:cover_medium], data_path: options[:data_path], password: options[:password])
else
  StegoToolkit::Core.new.extract(cover_medium: options[:cover_medium], password: options[:password])
end
