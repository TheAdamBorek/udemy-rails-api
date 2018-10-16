class User < ApplicationRecord
  has_one :access_token, dependent: :destroy
  validates :login, presence: true, uniqueness: true
  validates_presence_of :provider
end
