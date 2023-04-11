module Api 
    module V1
        class EmployeesController < ApplicationController 
            
            include JsonWebToken

            def login
                email = login_params[:email]
                password = login_params[:password]

                employee = Employee.where(email: email)[0]

                unless employee
                    return render json: {message: "There is no user with this email: #{email}"}, status: 404
                end

                unless password == employee.password
                    return render json: {message: "Incorrect password"}, status: 400
                end
                
                jwt_token = create_token(employee)
                render json: {emp: employee, Token: jwt_token}, status: 200
            end

            def index 
                employees = Employee.all 
                render json: EmployeeSerializer.new(employees).serialized_json
            end
            



            def create
                user = current_active_user
                if user.isadmin 
                    employee = Employee.new(employee_params)

                    if employee.save 
                        # jwt_token = create_token(employee)
                        render json: EmployeeSerializer.new(employee).serialized_json, status: 201
                        # render json: {emp: employee, token: jwt_token}
                    else
                        render json: {error: employee.errors.messages}
                    end
                else 
                    render json: {message: "Admin can only create employee account."}, status: 403
                end
            end

            def change_active_status
                user = current_active_user
                if user.isadmin 
                    employee = Employee.find(params[:id])

                    if employee.isactive?
                        employee.update(isactive: false)
                        render json: EmployeeSerializer.new(employee).serialized_json
                    elsif !employee.isactive?
                        employee.update(isactive: true)
                        render json: EmployeeSerializer.new(employee).serialized_json
                    else
                        render json: {message: employee.errors.messages}
                    end
                else
                    render json: {message: "Admin can only change the status"}
                end
            end


            def generate_expenditure_report 
                user = current_active_user
                if (user.isadmin)
                    employee = Employee.find(params[:id])
                    result = {"pending" => 0, "approved" => 0, "rejected"=>0, "total"=>0}
                    expen = employee.expenditures

                    expen.each do |expenditure|
                        if expenditure.expense_status == "pending"
                            result["pending"] = result["pending"] + expenditure.expense_amount
                        elsif expenditure.expense_status == "approved"
                            result["approved"] = result["approved"] + expenditure.expense_amount
                        elsif expenditure.expense_status == "rejected"
                            result["rejected"] = result["rejected"] + expenditure.expense_amount
                        end
                        result["total"] = result["total"] + expenditure.expense_amount
                        
                    end
                    # abc = Expenditure.all.group(_id: "expense_status")
                    # abc.pipeline

                    render json: result
                    ReportMailer.send_report_mail(employee, result).deliver_now
                    # render json: result
                else
                    render json: {message: "You are not authorize to generate report"}, status: 403
                end

            end

            # def search_employee 
            #     subname = params[:subname]
            #     result = []
            #     employees = Employee.all
            #     employees.each do |employee|
            #         # result.push(employee)
            #         # if employee.include?(subname)
            #         #     result.push(employee)
            #         # end
            #     end
            #     render json: result
            # end

            


            

            # def login_token
            #     token = request.headers["Authorization"].split(" ").last
            #     jwt_data = jwt_decode(token)
                
            #     userId = jwt_data[:user_id][:$oid]
                
            #     render json: Employee.find(userId)
            # end

            private 

                def login_params
                    params.require(:employee).permit(:email, :password)
                end
                # def search_params 
                #     params.require(:employee).permit(:subname)
                # end

                def employee_params
                    params.require(:employee).permit(:name, :email, :password, :department, :emp_id, :mobile)
                end

                def create_token(employee)
                    jwt_token = jwt_encode(
                        {:user_id => employee.id, 
                        :user_isactive => employee.isactive,
                        :user_isadmin => employee.isadmin },
                    )
                    return jwt_token
                end
        end
    end
end