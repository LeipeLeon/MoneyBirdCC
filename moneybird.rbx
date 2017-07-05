#!/usr/bin/env ruby
#
require 'dotenv/load'
require 'optparse'

unless File.file?('.env')
  puts "\nNO .env FILE!\n\n"
  puts "Copy the example and fill in the proper credentials"
  puts "\n\tcp .env.example .env\n\n"
  exit
end

options = {}
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ./moneybird.rbx <inputfile> <batchname> [-f]"

  opts.on("-f", "Do actual POST") do |v|
    options[:post] = true
  end

end
opt_parser.parse!

inputfile = ARGV.shift
raise "\n\nNeed to specify a file to process, e.g. transactions.txt\n\n" unless inputfile
batchname = ARGV.shift
raise "\n\nNeed to specify a (unique) batchname, e.g. 'cc_may'\n\n" unless batchname

require 'net/http'
require 'net/https'
require 'json'

def send_request(dict)
  uri = URI('https://moneybird.com/api/%s/%s/financial_statements.json' % [ENV.fetch('API_VERSION'), ENV.fetch('ADMINISTRATION_ID')])

  # Create client
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_PEER
  body = JSON.dump(dict)

  req =  Net::HTTP::Post.new(uri)
  req.add_field "Authorization", "Bearer #{ENV.fetch('API_KEY')}"
  req.add_field "Content-Type", "application/json; charset=utf-8"
  req.body = body

  res = http.request(req)
  puts "Response HTTP Status Code: #{res.code}"
  puts "Response HTTP Response Body: #{res.body}"
rescue StandardError => e
  puts "HTTP Request failed (#{e.message})"
end

class Mutation

  def initialize(day, month, year, txt, currency, amount)
    @day, @month, @year, @txt, @currency, @amount = day, month, year, [txt], currency, amount
  end

  def add(txt, currency, amount)
    @currency, @amount = currency, amount
    @txt << txt
  end

  def to_hash
    {
      date: "%4d-%02d-%02d" % [@year, @month, @day],
      message: @txt.join(' '),
      amount: @amount
    }
  end

end

mutations = []
File.open(inputfile, 'r') do |f|
  while line = f.gets
    # 03-07-2017	AMAZON MKTPLACE PMTS AMAZON.COM GBR	€	98,39
    date_or_text, txt_or_currency, currency_or_amount, amount = line.strip.split("\t")
    if /(?<day>\d{2})-(?<month>\d{2})-(?<year>\d{4})/ =~ date_or_text
      mutations << Mutation.new(day, month, year, txt_or_currency, currency_or_amount, amount) # unless /-/.match(amount)
    else # It's a text line
      mutations.last.add(date_or_text, txt_or_currency, currency_or_amount)
    end
  end
end

financial_mutations_attributes = {}
mutations.each_with_index { |m,idx| financial_mutations_attributes[idx] = m.to_hash }

dict = {
  # update_journal_entries: true,
  financial_statement: {
    financial_account_id: ENV.fetch('FINANCIAL_ACCOUNT_ID'),
    reference: batchname,
    financial_mutations_attributes: financial_mutations_attributes
  }
}

if options[:post]
  send_request(dict)
else
  require 'yaml'
  puts "Supply the -f parameter for actual posting the lines\n\nFound transactions:"
  puts dict.to_yaml
end
