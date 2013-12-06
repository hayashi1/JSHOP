require 'spec_helper'

describe 'Item' do
  context 'get_rakuten_items' do
    it 'locateのみ' do
      items = Item.get_rakuten_items('東京');
      expect(items).to have_at_least(1).items
    end
    it 'locate + genre' do
      items = Item.get_rakuten_items('東京', 551167);
      expect(items).to have_at_least(1).items
    end
  end
  context 'call_rakuten_api' do
    it 'locateのみ' do
      items = Item.call_rakuten_api('東京');
      expect(items).to have_at_least(1).items
    end
    it 'locate + genre' do
      items = Item.call_rakuten_api('東京', 551167);
      expect(items).to have_at_least(1).items
    end
  end
  context 'cut_locate' do
    it '東京都' do
      locate = Item.cut_locate('東京都');
      expect(locate).to eq('東京')
    end
    it '大阪府' do
      locate = Item.cut_locate('大阪府');
      expect(locate).to eq('大阪')
    end
    it '北海道' do
      locate = Item.cut_locate('北海道');
      expect(locate).to eq('北海道')
    end
    it '神奈川県' do
      locate = Item.cut_locate('神奈川県');
      expect(locate).to eq('神奈川')
    end
    it '横浜市' do
      locate = Item.cut_locate('横浜市');
      expect(locate).to eq('横浜')
    end
  end
  context 'make_cache_key' do
    it 'locateのみ' do
      key = Item.make_cache_key('東京');
      expect(key).to eq('東京')
    end
    it 'locate + genre' do
      key = Item.make_cache_key('東京', 551167);
      expect(key).to eq('東京_551167')
    end
  end
end
