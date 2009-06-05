require 'faker'

Sham.define do
  title             { Faker::Lorem.words(5).join(' ') }
  caption           { Faker::Lorem.words(15).join(' ') }
  asset_file_name   { Faker::Name.name + '.jpg' }
end

Asset.blueprint do 
  title
  caption
  asset_file_name 'asset.jpg'
  asset_content_type 'image/jpeg'
  asset_file_size '46248'
end