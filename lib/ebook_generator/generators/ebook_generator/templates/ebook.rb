class Ebook < ActiveRecord::Base
  extend FriendlyId
  has_many :sections, ->{ order(:position) }

  friendly_id :title, use: :slugged

  validates :title, presence: true
end
