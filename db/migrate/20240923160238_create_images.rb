class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.string :original_filename
      t.string :s3_key
      t.string :small_key
      t.string :medium_key
      t.string :large_key

      t.timestamps
    end
  end
end
