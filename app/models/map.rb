class Map < ApplicationRecord
	belongs_to :user, optional: true
	has_many :comments, dependent: :destroy

	Geocoder.configure(language: :ja)

	# if :latitude.blank? || :longitude.blank?
	# 	geocoded_by :address
	# 	after_validation :geocode
	# else
	# 	reverse_geocoded_by :latitude, :longitude
	# 	after_validation :reverse_geocode
	# end

  geocoded_by :address, if: ->(obj){ obj.latitude.blank? or obj.longitude.blank? }
  reverse_geocoded_by :latitude, :longitude, if: ->(obj){ not (obj.latitude.blank? or obj.longitude.blank?) }
  
  after_validation :geocode, if: ->(obj){ obj.latitude.blank? or obj.longitude.blank? }
  after_validation :reverse_geocode, if: ->(obj){ not (obj.latitude.blank? or obj.longitude.blank?) }
end
