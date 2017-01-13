class MapsController < ApplicationController
  before_action :set_map, only: [:edit, :update, :destroy]
  before_action :set_marker, only: [:edit]
  before_action :authenticate_user!, only: [:new, :edit]

  def index
    set_map_index(false, 35.170915, 136.8815369, "")
  end

  def ajax
    set_map_index(true, params[:lat], params[:lng], params[:search_params])
  end

  def show
    @map = Map.includes(:comments).order('comments.id desc').find(params[:id])
    set_marker
    session[:mapid] = @map.id
  end

  def edit
    #@map_tags = Map_tag.where('map_id = ? AND map_mster = ?', @map.id, true)
    unless @map.user_id == current_user.id
      redirect_to map_path(@map)
    end
    @map.tags.build
  end

  def new
    if current_user.user_level > 1
      @map = Map.new
      @map.tags.build
    else
      redirect_to maps_path
    end
  end

  def create
    unless current_user.user_level > 1
      redirect_to maps_path
    end

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
    #raise.params.inspect
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

  def destroy
    if current_user.user_level > 1 && @map.user_id == current_user.id
      @map.destroy
      redirect_to maps_path
    end
  end

  private
    def set_map
      @map = Map.find(params[:id])
    end

    def set_map_index(ajax_Judg, m_lat, m_lng, searchParams)
      if (ajax_Judg)
        sp = searchParams.gsub("　"," ")#全角スペースを半角スペースに変換
        sp2 = sp.gsub(" ","%,%")#半角スペースをカンマに変換(プレスホルダーの第二引数以降に使用する変数sp2に代入)
        sp2 = '%'+sp2+'%'
        sp2 = sp2.split(",")#ひとつの文字列だったsp2をカンマで区切って配列にする
        ph = " AND title like ?"
        sp.count(" ").times{
          ph += " AND title like ?"
        }
        @maps = Map.where("latitude > ? AND latitude < ? AND longitude > ? AND longitude < ?#{ph}",
                           params[:lower_lat],
                           params[:upper_lat],
                           params[:lower_lng],
                           params[:upper_lng],
                           *sp2 ).order(rank_av: :desc)#引数に配列を渡す時に先頭に*をつけると展開されて要素の数だけ引数の数も増えて渡される
      else
        @maps = Map.all
      end
      @hash = Gmaps4rails.build_markers(@maps) do |map, marker|
        marker.lat map.latitude
        marker.lng map.longitude
        #dis = distance(map.latitude, map.longitude, m_lat, m_lng)#特定の場所からの距離を計算する関数
        marker.infowindow render_to_string(:partial => "/maps/my_template", :locals => { :object => map})
        #marker.json({title: map.title, c_distance: dis, rank_av: map.rank_av, map_id: map.id})
        marker.json({title: map.title, rank_av: map.rank_av, map_id: map.id})
        
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
      # @hash.sort! do |a, b|
      #   a[:c_distance] <=> b[:c_distance]
      # end
      #rank_av上位20件を表示するようにする
      @hash.slice!(20..-1)
      
      #近い順に表示する
      #@hashDis = @hash
      # @hashDis.sort! do |a, b|
      #   a[:c_distance] <=> b[:c_distance]
      # end
    end

    def map_params
      params.require(:map).permit(:user_id,
                                  :map_id,
                                  :title,
                                  :address,
                                  :latitude,
                                  :longitude,
                                  tags_attributes: [:id, :tag_name, :tag_master, :_destroy])
    end

  def set_marker
    @hash = Gmaps4rails.build_markers(@map) do |map, marker|
      marker.lat map.latitude
      marker.lng map.longitude
      marker.json({title: map.title})
    end
  end
  #ある場所から、別の場所への距離を計算してkmで返す
  def distance(pos1, pos2, cen1, cen2)
    Geocoder::Calculations.distance_between([pos1, pos2], [cen1, cen2]) * 1000.0
  end

end
