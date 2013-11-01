class Item < ActiveRecord::Base
  def self.get_rakuten_items(locate='', type='all')
    rakuten_items = []
    begin
      return [] if locate.blank?
      locate = self.cut_locate(locate)
      case type
      when 'foods'
        genre_ids = [551167]
      when 'others'
        genre_ids = [215783]
      else
        genre_ids = [0]
      end
      genre_ids.each do |genre_id|
        genre_items = [];
        httpClient = HTTPClient.new
        data = httpClient.get_content('https://app.rakuten.co.jp/services/api/IchibaItem/Search/20130805', {
          'applicationId' => '1040308007638376273',
          'affiliateId'   => '11b678a4.eca51fe8.11b678a5.89b6a8b9',
          'keyword'       => locate << '　土産',
          'genreId'       => genre_id,
          'imageFlag'     => 1,
          'hits'          => 20,
          'sort'          => '-reviewCount',
          'page'          => 1
        })
        jsonData = JSON.parse data
        jsonData['Items'].each do | itemData |
          item = itemData['Item']
          genre_items << item
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
end
