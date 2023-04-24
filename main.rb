require 'ofx'
require 'airrecord'
require 'pry'
require_relative 'models/transaction.rb'

raise ArgumentError if ARGV.length.zero?

## Ruby 3 ofx quick fix
OFX::Parser::OFX102.class_eval do
  def build_amount(element)
    BigDecimal(element.search("trnamt").inner_text)
  end
end

subcommand              = ARGV[0]
airtable_personal_token = ENV.fetch('AIRTABLE_PERSONAL_TOKEN')
Airrecord.api_key = airtable_personal_token

if subcommand == 'import'
  ofx_file = ARGV[1]
  raise ArgumentError unless ofx_file

  OFX(ofx_file) do
    account.transactions.each do |transaction|
      Transaction.create(
        'Descrição':      transaction.memo,
        'Montante':       transaction.amount.to_f,
        'Pago em':        transaction.posted_at,
      )
    end
  end
end