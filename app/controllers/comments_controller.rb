require 'kconv'
require 'aws-sdk-v1'
require 'RMagick'#require sudo yum install ImageMagick ImageMagick-devel -y

class CommentsController < ApplicationController
  
  before_action :authenticate_user!, only: [:new, :edit]
  before_action :set_comment_id, only: [:show, :edit, :update, :destroy]
  AWS.config(access_key_id: ENV["ACCESS_KEY_ID"], secret_access_key: ENV["SECRET_ACCESS_KEY"], region: 'ap-northeast-1')

  def show
    @up_result = session[:up_result]
    session[:up_result] = nil
  end

  def new
    if 0 < Comment.where('user_id = ? AND map_id = ?', current_user.id, session[:mapid]).count
      @comment = Comment.where('user_id = ? AND map_id = ?', current_user.id, session[:mapid]).first
      redirect_to comment_path(@comment) and return
    end

  	@comment = Comment.new
    @comment.pictures.build
    #session[:comment_id] = @comment.id
  	@mapid = session[:mapid]
  end

  def create
    if 0 < Comment.where('user_id = ? AND map_id = ?', current_user.id, session[:mapid]).count
      @comment = Comment.where('user_id = ? AND map_id = ?', current_user.id, session[:mapid]).first
      redirect_to comment_path(@comment) and return
    end

  	@comment = Comment.new(comment_params)
  	@comment.user_id = current_user.id
    @map = Map.find(comment_params[:map_id])
    @up_result = {}

  	if @comment.save
      if Rails.env == 'production'
        picture_up_production
      else
        picture_up_develop
      end
      @map.rank_av = Comment.where('map_id = ?', comment_params[:map_id]).average(:star_rank_score).to_f
      @map.save
      
      session[:up_result] = @up_result
  		redirect_to map_path(comment_params[:map_id]) and return
  	else
  		render 'new' and return
  	end
  end

  def edit
  end

  def update
    #raise params.inspect
    @map = Map.find(@comment.map_id)
    @up_result = {}

    if @comment.update(comment_params)
      if Rails.env == 'production'
        picture_up_production
      else
        picture_up_develop
      end
      @map.rank_av = Comment.where('map_id = ?', @comment.map_id).average(:star_rank_score).to_f
      @map.save

      session[:up_result] = @up_result
      redirect_to comment_path params[:id] and return
    else
      render 'new' and return
    end
  end

  def destroy
    if Rails.env == 'production'
      @comment.pictures.each do |picture|
        s3 = AWS::S3.new
        s3.buckets[ENV["AWS_S3_BUCKET"]].objects["images/"+picture.id.to_s+File.extname("#{ picture.picture_name }").downcase].delete
      end
    end
    @comment.destroy
    redirect_to map_path(session[:mapid])
  end

  private
  	def comment_params
  		params.require(:comment).permit(:user_id, :map_id, :title, :text, :star_rank_score)
  	end

    def set_comment_id
      @comment = Comment.find params[:id]
    end

    def picture_up_production
      name = 'string'

      s3 = AWS::S3.new
      bucket = s3.buckets[ENV["AWS_S3_BUCKET"]]

      unless params[:comment][:picture_file].nil?
        params[:comment][:picture_file].each do |value|
          file = value
          name = file.original_filename 
          ext = name[name.rindex('.') + 1, 4].downcase

          perms = ['.jpg', '.jpeg', '.gif', '.png']
          if !perms.include?(File.extname(name).downcase)
            @up_result[name.to_s] = 'アップロードできるのは画像ファイルのみです。'
          elsif file.size > 10.megabyte
            @up_result[name.to_s] = 'ファイルサイズは10MBまでです。'
          else
            name = name.kconv(Kconv::SJIS, Kconv::UTF8)
            @picture = Picture.new
            @picture.picture_name = name
            @picture.comment_id = @comment.id
            @picture.picture_path = ENV["AWS_PICTURE_PATH"]+@picture.id.to_s
            @picture.save

            file_full_path="images/"+@picture.id.to_s+File.extname(name).downcase
            object = bucket.objects[file_full_path]
            object.write(file ,:acl => :public_read)

            original = Magick::Image.from_blob(File.read(file.tempfile)).shift
            minpic = original.resize_to_fit(250, 250)
            #minpic.write(bucket.objects[file_full_path])
            file_full_path="images/"+@picture.id.to_s+"min"+File.extname(name).downcase
            object = bucket.objects[file_full_path]
            object.write(minpic.to_blob ,:acl => :public_read)

            @up_result[name.to_s] = '画像をアップロードしました。'
          end
        end
      end
    end

    def picture_up_develop
      name = 'string'
      unless params[:comment][:picture_file].nil?
        params[:comment][:picture_file].each do |value|
          file = value
          name = file.original_filename 
          ext = name[name.rindex('.') + 1, 4].downcase
          perms = ['.jpg', '.jpeg', '.gif', '.png']
          if !perms.include?(File.extname(name).downcase)
            @up_result[name.to_s] = 'アップロードできるのは画像ファイルのみです。'
          elsif file.size > 10.megabyte
            @up_result[name.to_s] = 'ファイルサイズは10MBまでです。'
          else
            name = name.kconv(Kconv::SJIS, Kconv::UTF8)
            @picture = Picture.new
            @picture.picture_name = value.original_filename
            @picture.comment_id = @comment.id
            @picture.save
            File.open("public/docs/#{@picture.id}"+File.extname(name).downcase, 'wb') { |f| f.write(file.read) }

            original = Magick::Image.from_blob(File.read(file.tempfile)).shift
            minpic = original.resize_to_fit(250, 250)
            minpic.write("public/docs/#{@picture.id}min"+File.extname(name).downcase)
            @up_result[name.to_s] = '画像をアップロードしました。'
          end
        end
      end
    end

end
