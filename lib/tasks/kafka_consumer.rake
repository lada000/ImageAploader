namespace :kafka do
  desc 'Consume messages from processed_images topic'
  task consume_processed_images: :environment do
    consumer = ImageProcessorConsumer.new
    consumer.run
  end
end
