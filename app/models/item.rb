class Item < ActiveRecord::Base
  # 商品名から除外する文言の正規表現
  REMOVE_REGEXPS = [
    /【[\S|\s]+?】/,
    /\[[\S|\s]+?\]/,
    /［[\S|\s]+?\］/,
    /（国内土産[\S|\s]+?\）/,
    /送料無料/,
    /fs3gm/,
    /◎メール便不可：宅配便限定◎◆楽天ランキング1位獲得◆お土産にも最適の/
  ]
  REMOVE_CODES = {
    '東京' => [
      'kangurume:10002301',
      'kioskgift:10000045',
      'kangurume:10002868',
      'kyo-yakiguri:10000005'
    ],
    '北海道' => [
      'yuuzen:10000688',
      'mashleshop:10000060',
      'kashi:10000157',
      'yuuzen:10000014',
      'daily-3:10130117',
      'yuuzen:10000404',
      'yuuzen:10000601',
      'yuuzen:10000411',
      'tennenseikatsu:10000152',
      'yuuzen:10000010',
      'yuuzen:10000016',
      'yuuzen:10000408',
      'sushiko:10000027',
      'yuuzen:10000130',
      'yuuzen:10000139',
      'miyakodasihonpo:10000017',
      'kamakurayama:10000106'
    ],
    '沖縄' => [
      'yuuzen:10000688',
      'kashi:10000157',
      'yuuzen:10000014',
      'ksfoods:10000076',
      'daily-3:10130117',
      'rikaryo:10005885',
      'ohshimaya:10000139',
      'kamenoko:10000022',
      'kyogashi-fukuya:10000384',
      'yuuzen:10000014',
      'ksfoods:10000076',
      'yuuzen:10000404',
      'okipota:10000405',
      'yuuzen:10000601',
      'y-chuukagai:10000564',
      'yuuzen:10000411',
      'yuuzen:10000010',
      'ksfoods:10000117',
      'okipota:10000275',
      'okinawa-takarajima:10000001',
      'yuuzen:10000016',
      'yuuzen:10000408',
      'sushiko:10000027',
      'okinawa-takarajima:10000000'
    ]
  }

  def self.get_rakuten_items(locate='', genre_id=nil)
    rakuten_items = []
    begin
      return [] if locate.blank?
      locate = self.cut_locate(locate)
      genre_ids = [genre_id]
      genre_ids.each do |genre_id|
        genre_items = [];
        remove_code = self::REMOVE_CODES[locate].present? ? self::REMOVE_CODES[locate] : []
        count       = 0;
        page        = 1;
        while true
          httpClient = HTTPClient.new
          data = httpClient.get_content('https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805', {
            'applicationId' => '1040308007638376273',
            'affiliateId'   => '11b678a4.eca51fe8.11b678a5.89b6a8b9',
            'keyword'       => locate + '　土産',
            'genreId'       => genre_id,
            'imageFlag'     => 1,
            'hits'          => 30,
            'sort'          => '-reviewCount',
            'page'          => page
          })
          jsonData = JSON.parse data
          jsonData['Items'].each do | itemData |
            item = itemData['Item']
            # 評価が低い商品を除外する
            next if item['reviewAverage'].to_f < 3.5
            # 想定外のデータを除外する
            next if remove_code.include?(item['itemCode'])
            # 商品名から不要な部分を削除する
            item['itemName'] = self.clean_itemname(item['itemName'])
            genre_items << item
            count += 1
            break if count == 20
          end
          break if count == 20 || page == jsonData['pageCount'].to_i
          page += 1
          # 無限ループ阻止用
          break if page > 3
        end
        rakuten_items.concat genre_items
      end
    rescue HTTPClient::BadResponseError => e
      p e.res.code # Error Code
      p e.res.body # Body
    rescue HTTPClient::TimeoutError => e
      p "Timeout Error"
    ensure
      return rakuten_items
    end
  end

  private
  # 北海道以外は末尾の都府県を取り除く
  def self.cut_locate(locate)
    locate.gsub(/(都|府|県)$/u, "")
  end
  # 商品名から補足説明を取り除く
  def self.clean_itemname(name)
    self::REMOVE_REGEXPS.each do |reg|
      name = name.gsub(reg, "")
    end
    name.strip
  end
end
