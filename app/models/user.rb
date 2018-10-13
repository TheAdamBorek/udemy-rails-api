class User < ApplicationRecord
  validates :login, presence: true, uniqueness: true
  validates_presence_of :provider
end
