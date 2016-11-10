class Map < ApplicationRecord
	Geocoder.configure(language: :ja)
	if :latitude.nil? || :longitude.nil?
		geocoded_by :address
		after_validation :geocode
	else
		reverse_geocoded_by :latitude, :longitude
		after_validation :reverse_geocode
	end
end
