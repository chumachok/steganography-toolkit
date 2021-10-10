require "optparse"
require_relative "stego_toolkit/core"

PROGNAME = File.basename(__FILE__)

# ruby main.rb -m fixtures/cover_medium.bmp -d fixtures/secret.png -o message.bmp -p secret --embed
# ruby main.rb -m output/encrypted/message.bmp -p secret --extract

options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "usage: ruby #{PROGNAME} --medium <medium> --data <data> --password <password>"

  opts.on("-m", "--medium medium", "specify cover medium") do |medium|
    options[:cover_medium] = medium
  end

  opts.on("-d", "--data data", "specify path to secret") do |data|
    options[:data] = data
  end

  opts.on("-o", "--output filename", "specify output filename") do |filename|
    options[:output_filename] = filename
  end

  opts.on("-c", "--cipher cipher", "specify cipher") do |cipher|
    options[:cipher] = cipher
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
  $stderr.puts "either the --embed or --extract flag must be present"
  exit(1)
end

if options[:embed]
  StegoToolkit::Core.new.embed(
    cover_medium: options[:cover_medium],
    data: options[:data],
    output_filename: options[:output_filename],
    cipher: options[:cipher],
    password: options[:password],
  )
else
  StegoToolkit::Core.new.extract(
    cover_medium: options[:cover_medium],
    cipher: options[:cipher],
    password: options[:password],
  )
end
