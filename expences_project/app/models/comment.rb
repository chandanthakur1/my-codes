class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  field :name, type: String
  field :content, type: String
  belongs_to :expenditure
end
