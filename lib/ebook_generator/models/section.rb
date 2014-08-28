class Section < ActiveRecord::Base
  belongs_to :ebook
  acts_as_list scope: :ebook

  validates :title, :presence => true
  validates :content, :presence => true

end
