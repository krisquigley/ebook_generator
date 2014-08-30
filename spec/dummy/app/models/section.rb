class Section < ActiveRecord::Base
  belongs_to :ebook

  validates :title, :presence => true
  validates :content, :presence => true

end
