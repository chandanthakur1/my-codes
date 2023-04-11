class EmployeeSerializer
  include FastJsonapi::ObjectSerializer
  attributes :name, :email, :password, :department, :emp_id, :mobile, :isactive, :isadmin, :expenditures
end
