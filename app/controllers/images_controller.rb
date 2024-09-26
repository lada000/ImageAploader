class ImagesController < ApplicationController
  def create
    image_file = params[:image]
    unless image_file
      render json: { error: 'No image provided' }, status: :bad_request
      return
    end

    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['AWS_S3_BUCKET'])

    s3_key = "original/#{SecureRandom.uuid}_#{image_file.original_filename}"

    obj = bucket.object(s3_key)
    obj.put(body: image_file.read)

    image = Image.create!(
      original_filename: image_file.original_filename,
      s3_key: s3_key
    )

    producer = $kafka.producer
    payload = {
      image_id: image.id,
      s3_key: s3_key
    }.to_json
    producer.produce(payload, topic: 'images').delivery_handle.wait

    render json: { id: image.id }, status: :created
  end

  def show
    image = Image.find(params[:id])
    size = params[:size]

    s3_key = case size
             when 'small'
               image.small_key
             when 'medium'
               image.medium_key
             when 'large'
               image.large_key
             else
               render json: { error: 'Invalid size' }, status: :bad_request
               return
             end

    unless s3_key
      render json: { error: 'Image not processed yet' }, status: :not_found
      return
    end

    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(ENV['AWS_S3_BUCKET'])
    obj = bucket.object(s3_key)

    url = obj.presigned_url(:get, expires_in: 120) 

    render json: { url: url }
  end
end
