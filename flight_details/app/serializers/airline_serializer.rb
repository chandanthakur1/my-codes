class AirlineSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :image_url, :slug, :reviews
end
