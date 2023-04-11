class Expenditure
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :comments

  field :expense_invoice, type: Integer
  field :expense_details, type: String
  field :expense_status, type: String
  field :expense_amount, type: Integer
  field :expense_document, type: String
  field :expense_date, type: Date
  belongs_to :employee

  validates :expense_invoice, presence: true, uniqueness: true
  # validated :expense_status, inclusion: { in: %w(pending approved rejected), message: "%{value} is not a valid status. You can only add Pending, Rejected and Approved" }
  
  # before_create :set_expense_status

  
end
