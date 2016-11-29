class MapsController < ApplicationController
	before_action :set_map, only: [:show, :edit, :update, :destroy]
	before_action :set_marker, only: [:show, :edit]
	before_action :authenticate_user!, only: [:new, :edit]

	def index
		@maps = Map.all
		@hash = Gmaps4rails.build_markers(@maps) do |map, marker|
			marker.lat map.latitude
			marker.lng map.longitude
			dis = distance(map.latitude, map.longitude, 35.170915, 136.8815369)#特定の場所からの距離を計算する関数
			marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
			marker.json({title: map.title, c_distance: dis})
			
			unless map.rank_av.nil?
				if map.rank_av >= 4
					marker.picture({
						url: ActionController::Base.helpers.asset_path('gold'),
						width: "26",
						height: "26"
					})
				elsif map.rank_av >= 2
					marker.picture({
						url: ActionController::Base.helpers.asset_path('silver'),
						width: "26",
						height: "26"
					})
				else
					marker.picture({
						url: ActionController::Base.helpers.asset_path('bronze'),
						width: "26",
						height: "26"
					})
				end
			else
				marker.picture({
					url: ActionController::Base.helpers.asset_path('bronze'),
					width: "26",
					height: "26"
				})
			end
		end
		#マーカーのハッシュを近い順にソート
		@hash.sort! do |a, b|
		  a[:c_distance] <=> b[:c_distance]
		end
		#centerからの距離近い順で上位3件を表示するようにする
		@hash.slice!(3..-1)
		@hash.each do |hash, v|
			p 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
			p hash[:c_distance]
		end
	end

	def ajax
		raise params.inspect
		@maps = Map.all
		@hash = Gmaps4rails.build_markers(@maps) do |map, marker|
			marker.lat map.latitude
			marker.lng map.longitude
			dis = distance(map.latitude, map.longitude, lat, lng)#特定の場所からの距離を計算する関数
			marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
			marker.json({title: map.title, c_distance: dis})
			
			unless map.rank_av.nil?
				if map.rank_av >= 4
					marker.picture({
						url: ActionController::Base.helpers.asset_path('gold'),
						width: "26",
						height: "26"
					})
				elsif map.rank_av >= 2
					marker.picture({
						url: ActionController::Base.helpers.asset_path('silver'),
						width: "26",
						height: "26"
					})
				else
					marker.picture({
						url: ActionController::Base.helpers.asset_path('bronze'),
						width: "26",
						height: "26"
					})
				end
			else
				marker.picture({
					url: ActionController::Base.helpers.asset_path('bronze'),
					width: "26",
					height: "26"
				})
			end
		end
		#マーカーのハッシュを近い順にソート
		@hash.sort! do |a, b|
		  a[:c_distance] <=> b[:c_distance]
		end
		#centerからの距離近い順で上位3件を表示するようにする
		@hash.slice!(3..-1)
		@hash.each do |hash, v|
			p 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
			p hash[:c_distance]
		end
	end

	def show
		#@comments = Comment.where('map_id = ?', params[:id] ).order(created_at: :desc)
		#@comment = Comment.new
		session[:mapid] = @map.id
	end

	def edit
		unless @map.user_id == current_user.id
			redirect_to map_path(@map)
		end
	end

	def new
		@map = Map.new
	end

	def create
    @map = Map.new(map_params)
    @map.user_id = current_user.id
    respond_to do |format|
      if @map.save
        format.html { redirect_to @map, notice: 'map was successfully created.' }
        format.json { render :show, status: :created, location: @map }
      else
        format.html { render :new }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
	end

	def update
	respond_to do |format|
	  if @map.update(map_params)
	    format.html { redirect_to @map, notice: 'map was successfully updated.' }
	    format.json { render :show, status: :ok, location: @map }
	  else
	    format.html { render :edit }
	    format.json { render json: @map.errors, status: :unprocessable_entity }
	  end
	end
	end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_map
      @map = Map.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def map_params
      params.require(:map).permit(:user_id, :map_id, :title, :address, :latitude, :longitude)
    end

	def set_marker
		@hash = Gmaps4rails.build_markers(@map) do |map, marker|
			marker.lat map.latitude
			marker.lng map.longitude
			#marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
			marker.json({title: map.title})
		end
	end

	def distance(pos1, pos2, cen1, cen2)
		Geocoder::Calculations.distance_between([pos1, pos2], [cen1, cen2]) * 1000.0
	end

end
