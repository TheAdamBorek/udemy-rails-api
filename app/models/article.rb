class Article < ApplicationRecord
  validates_presence_of :title, :content
  validates :slug, presence: true, uniqueness: true

  def self.recent
    order(created_at: :desc)
  end
end
