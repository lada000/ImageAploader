class ImageProcessorConsumer
  def initialize
    consumer_config = {
      'bootstrap.servers' => ENV['KAFKA_BROKERS'],
      'group.id' => 'image_uploader_group'
    }
    kafka_consumer = Rdkafka::Config.new(consumer_config)
    @consumer = kafka_consumer.consumer
    @consumer.subscribe('processed_images')
  end

  def run
    @consumer.each do |message|
      data = JSON.parse(message.payload)
      image = Image.find(data['image_id'])

      image.update!(
        small_key: data['small_key'],
        medium_key: data['medium_key'],
        large_key: data['large_key']
      )
    end
  end
end

