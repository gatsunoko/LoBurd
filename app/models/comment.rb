class Comment < ApplicationRecord
	belongs_to :user, optional: true
	belongs_to :map
	has_many :pictures, dependent: :destroy
	accepts_nested_attributes_for :pictures
end
