class MapsController < ApplicationController
	before_action :set_map, only: [:show, :edit, :update, :destroy]
	before_action :set_marker, only: [:index, :show, :edit]

	def index
		@maps = Map.all
		@hash = Gmaps4rails.build_markers(@maps) do |map, marker|
			marker.lat map.latitude
			marker.lng map.longitude
			marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
			marker.json({title: map.title})
			marker.picture({
			  url: ActionController::Base.helpers.asset_path("puyo.png"),
			  width: "35",
			  height: "35"
			})
		end
	end

	def show
	end

	def edit
	end

	def new
		@map = Map.new
	end

	def create
    @map = Map.new(map_params)

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
      params.require(:map).permit(:map_id, :title, :address, :latitude, :longitude)
    end

	 def set_marker
	  @hash = Gmaps4rails.build_markers(@map) do |map, marker|
	    marker.lat map.latitude
	    marker.lng map.longitude
	    #marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
	    marker.json({title: map.title})
	    marker.picture({
	      url: ActionController::Base.helpers.asset_path("puyo.png"),
	      width: "25",
	      height: "25"
	    })
	  end
	end
end
