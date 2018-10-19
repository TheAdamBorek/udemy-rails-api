class Article < ApplicationRecord
  validates_presence_of :title, :content
  validates :slug, presence: true, uniqueness: true
  after_initialize :generate_slug
  
  def self.recent
    order(created_at: :desc)
  end

  private

  def generate_slug
    if slug.blank? && !title.blank?
      self.slug = title.parameterize
    end
  end
end
