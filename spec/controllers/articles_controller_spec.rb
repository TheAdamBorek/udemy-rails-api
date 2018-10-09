require 'rails_helper'

describe ArticlesController do
  describe '#index' do
    subject { get :index }

    it 'should return success response' do
      subject
      expect(response).to have_http_status :ok
    end

    it 'should return proper json' do
      create_list :article, 2
      subject
      expect(json_data.length).to eq 2
      Article.recent.each_with_index do |article, index|
        json_attributes = json_data[index]['attributes']
        expect(json_attributes).to eq(expected_attributes_for article)
      end
    end

    it 'should return articles in the descending order by date (newest first)' do
      older_article = create :article
      newer_article = create :article
      subject
      expect(json_data.first['id']).to eq newer_article.id.to_s
      expect(json_data.last['id']).to eq older_article.id.to_s
    end
  end

  describe '#show' do
    let(:article) { create :article }
    subject { get :show, params:  { id: article.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status :ok
    end

    it 'should render an article with given id' do
      subject
      expect(json_data['attributes']).to eq expected_attributes_for(article)
    end
  end

  def expected_attributes_for(article)
    {
        'title'   => article.title,
        'content' => article.content,
        'slug'    => article.slug
    }
  end
end