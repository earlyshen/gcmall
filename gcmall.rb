#!/usr/bin/env ruby

require 'CSV'

def getBalance(card, month, year, cvv, postal)
  postal = postal == nil ? "00000" : postal
  url = 'https://mygift.giftcardmall.com/Card/Login?returnUrl=Transactions'
  `curl -sS -c cookie --data "PostalCode=#{postal}&CardNumber=#{card}&ExpirationMonth=#{month}&ExpirationYear=#{year}&SecurityCode=#{cvv}" #{url}`
  response = `curl -sS -b cookie -H "Referer: #{url}" 'https://mygift.giftcardmall.com/Card/Transactions'`
  matches = response.scan(/<\/h6><h5>([\d\.\$]+)<\/h5><\/td>/i)
  if matches.count == 3
    last4 = matches[0][0]
    available = matches[1][0]
    initial = matches[2][0]
    return last4, available, initial
  else
    return nil, nil, nil
  end

end

printf("%13s %10s %8s\n",'Last 4 Digit', 'Available', 'Initial')
print "====================================\n"

CSV.foreach("cards.csv", { headers: true, header_converters: :symbol }) do |row|
  card = row.to_hash
  last4, available, initial = getBalance(card[:card_number], card[:month], card[:year], card[:cvv], card[:zip_code])
  if last4
    printf("%13s %10s %8s\n", last4, available, initial)
  else
    last4 = card[:card_number][-4,4]
    printf("%13s %19s\n", last4, 'Card not found')
  end
end

print "====================================\n"
