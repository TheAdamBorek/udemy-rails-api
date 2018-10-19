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
    subject { get :show, params: {id: article.id} }

    it 'should return success response' do
      subject
      expect(response).to have_http_status :ok
    end

    it 'should render an article with given id' do
      subject
      expect(json_data['attributes']).to eq expected_attributes_for(article)
    end
  end

  describe '#create' do
    subject { post :create }

    it_behaves_like 'resource_with_restricted_access'

    context 'when authenticated' do
      let(:user) { create :user }
      let(:access_token) { user.create_access_token }

      before { request.headers['Authorization'] = "Bearer #{access_token.token}" }

      context 'when form is invalid' do
        let(:invalid_params) do
          {
              data: {
                  attributes: {
                      title:   '',
                      content: ''
                  }
              }
          }
        end
        subject { post :create, params: invalid_params }

        it "should has proper status code" do
          subject
          expect(response).to have_http_status :unprocessable_entity
        end

        it "should return an validation error" do
          subject
          expect(json_errors).to include({"source" => {"pointer" => "/data/attributes/title"},
                                          "detail" => "can't be blank"},
                                         "source" => {"pointer" => "/data/attributes/content"},
                                         "detail" => "can't be blank")
        end
      end

      context 'when form is valid' do
        let(:valid_params) do
          {
              'data' => {
                  'attributes' => {
                      'title'   => 'The title',
                      'content' => 'The content'
                  }
              }
          }
        end

        subject { post :create, params: valid_params }

        it "responses with 201 status" do
          subject
          expect(response).to have_http_status :created
        end

        it "saves the article" do
          expect { subject }.to change { Article.count }.by 1
        end

        it "response returns saved article" do
          subject
          expect(json_data['attributes']).to include valid_params['data']['attributes'].merge('slug' => 'the-title')
        end
      end
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