# -*- coding: utf-8 -*-
require 'httpclient'
require 'json'

begin
 httpClient = HTTPClient.new
 data = httpClient.get_content('https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805', {
  'applicationId' =>'1040308007638376273',
  'affiliateId'   =>'11b678a4.eca51fe8.11b678a5.89b6a8b9',
  'keyword'       =>'うどん',
  'hits'          =>'3',
 })
 jsonData = JSON.parse data

 jsonData['Items'].each do | itemData |
  item = itemData['Item']

  p "#{item['itemName']} #{item['itemPrice']}円"
 end
rescue HTTPClient::BadResponseError => e
 p e.res.code # Error Code
 p e.res.baby # Body
rescue HTTPClient::TimeoutError => e
 p "Timeout Error"
end
