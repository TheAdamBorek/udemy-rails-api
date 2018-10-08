class Article < ApplicationRecord
  validates_presence_of :title, :content
  validates :slug, presence: true, uniqueness: true
end
