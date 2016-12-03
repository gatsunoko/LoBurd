class Picture < ApplicationRecord
	belongs_to :comment, optional: true
end
