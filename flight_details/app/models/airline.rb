class Airline
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :image_url, type: String
  field :slug, type: String

  has_many :reviews


  before_create :slugify 

  def slugify 
    self.slug = name.parameterize
  end

end
