class Comment < ApplicationRecord
	belongs_to :user, optional: true
	has_many :pictures
	accepts_nested_attributes_for :pictures
end
