require 'spec_helper'

describe 'Item' do
  context 'get_rakuten_items' do
    it '引数なし' do
      items = Item.get_rakuten_items();
      expect(items).to have(0).items
    end
    it '引数あり' do
      items = Item.get_rakuten_items('東京');
      expect(items).to have_at_least(1).items
    end
  end
end
