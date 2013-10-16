require 'spec_helper'

describe 'Item' do
  context 'getRakutenItems' do
    it '引数なし' do
      items = Item.getRakutenItems();
      expect(items).to have_at_least(1).items
    end
    it '引数あり' do
      items = Item.getRakutenItems('東京');
      expect(items).to have_at_least(1).items
    end
  end
end
