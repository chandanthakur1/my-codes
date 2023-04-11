class ExpenditureSerializer
  include FastJsonapi::ObjectSerializer
  attributes :expense_invoice, :expense_details, :expense_status, :expense_amount, :expense_document, :expense_date, :employee_id, :comments
end
