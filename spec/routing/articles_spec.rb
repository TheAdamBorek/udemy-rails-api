require 'rails_helper'

describe 'articles routes' do
  it 'should route to articles index' do
    expect(get 'articles').to route_to 'articles#index'
  end

  context 'for given id' do
    it 'should route to the article show action' do
      expect(get 'articles/1').to route_to 'articles#show', id: '1'
    end
  end
end