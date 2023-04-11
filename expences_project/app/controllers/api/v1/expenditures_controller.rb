require 'net/http'
require 'uri'
require 'json'

module Api 
    module V1
        class ExpendituresController < ApplicationController
            include JsonWebToken
            # inlcude Net
            # include URI

            def index
                expenditures = Expenditure.all
                render json: ExpenditureSerializer.new(expenditures).serialized_json
            end

            def show
                user = current_active_user
                expenditure = Expenditure.where(id: params[:id])[0]
                unless expenditure 
                    return render json: {error: "There is no Expenditure with this ID"}, status: 400
                end
                if ((user.id == expenditure.employee_id and user.isactive) or user.isadmin)
                    render json: ExpenditureSerializer.new(expenditure).serialized_json
                else
                    render json: {error: "You don't have permission to view this document"}, status: 403
                end
            end

            def abc
                user = current_active_user
                render json: user
            end

            def create
                user = current_active_user
                data = expenditure_params
                data[:employee_id] = user.id
                url = URI("https://my.api.mockaroo.com/invoices.json")

                https = Net::HTTP.new(url.host, url.port)
                https.use_ssl = true

                request = Net::HTTP::Post.new(url)
                request["X-API-Key"] = "b490bb80"
                request["Content-Type"] = "application/json"
                request.body = JSON.dump({
                    "invoice_id": data[:expense_invoice]
                })

                response = https.request(request)
                res = response.read_body
                temp = ActiveSupport::JSON.decode res
                if !temp['status']
                    data[:expense_status] = "rejected"
                else
                    data[:expense_status] = "pending"
                end
                
                # puts "DAta is #{data}"

                expenditure = Expenditure.new(data)
                if user.isadmin
                    return render json: {message: "Admin Cannot create Expenses for User"}, status: 403
                elsif !user.isactive
                    return render json: {message: "You are not Active Employee so you cannot create Expenses"}, status: 403
                end
                
                

                if expenditure.save
                    
                    render json: ExpenditureSerializer.new(expenditure).serialized_json, status: 201
                else
                    render json: {error: expenditure.errors.messages}
                end
            end

            def update
                user = current_active_user
                expenditure = Expenditure.where(id: params[:id])[0]


                if !expenditure
                    return render json: {error: "There is no Expenditure with this ID"}, status: 400
                elsif !user.isactive
                    return render json: {message: "You are not Active Employee so you cannot edit this Expenses"}, status: 403
                elsif expenditure.expense_status != 'pending'
                    return render json: {error: "The Expenditure is already #{expenditure.expense_status}"}, status: 403
                end
                
                
                if ((user.id == expenditure.employee_id) or user.isadmin)
                    if expenditure.update(expenditure_params)
                        render json: ExpenditureSerializer.new(expenditure).serialized_json
                    else
                        render json: {error: expenditure.errors.messages}
                    end 
                else
                    render json: {error: "Orignal User have only authority to change this expenditure"}, status: 403
                end
            end

            
            def destroy
                user = current_active_user
                expenditure = Expenditure.where(id: params[:id])[0]
                unless expenditure 
                    return render json: {error: "There is no Expenditure with this ID"}, status: 400
                end

                if expenditure.expense_status != 'pending'
                    return render json: {error: "The Expenditure is already #{expenditure.expense_status}"}, status: 403
                end

                if ((user.id == expenditure.employee_id and user.isactive) or user.isadmin)
                    if expenditure.destroy
                        head :no_content, status: 204
                    else
                        render json: {error: expenditure.errors.messages}
                    end 
                else
                    render json: {error: "Orignal User have only authority to delete this expenditure"}, status: 403
                end
            end

            def change_expense_status
                user = current_active_user
                if user.isadmin
                    
                    expenditure = Expenditure.find(params[:id])



                    if expenditure.update(change_status_params)
                        state = change_status_params[:expense_status]
                        render json: ExpenditureSerializer.new(expenditure).serialized_json
                        # puts expenditure.id 
                        # puts expenditure.expense_invoice
                        # puts expenditure.expense_details
                        ResultMailer.send_result_mail(state, expenditure).deliver_now
                    else
                        render json: {error: expenditure.errors.messages}
                    end
                else 
                    render json: {message: "Only Admin can approve this Expense"}
                end
            end


            


            private 
                def expenditure_params
                    params.require(:expenditure).permit(:expense_invoice, :expense_details, :expense_amount, :expense_document, :expense_date)
                end

                def change_status_params 
                    params.require(:expenditure).permit(:expense_status)
                end

                
        end
    end
end