class Review
  include Mongoid::Document
  include Mongoid::Timestamps
  field :title, type: String
  field :description, type: String
  field :score, type: Integer
  
  belongs_to :airline
end
