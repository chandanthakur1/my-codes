class Employee
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :expenditures

  field :name, type: String
  field :email, type: String
  field :password, type: String
  field :department, type: String
  field :emp_id, type: String
  field :mobile, type: String
  field :isactive, type: Mongoid::Boolean
  field :isadmin, type: Mongoid::Boolean


  validates :email, :emp_id, presence: true, uniqueness: true
  # validates :mobile, presence: true, uniqueness: true, length: {maximum: 10, minimum: 10}
  
  

  before_create :setData

  def setData
    self.isactive = true
    self.isadmin = false
    
  end
  
  
end
