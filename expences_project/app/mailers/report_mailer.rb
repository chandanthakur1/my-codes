class ReportMailer < ApplicationMailer
    def send_report_mail(employee, result)
        @result = result 
        @employee = employee
        mail(
            to:"thakurchandan4562@gmail.com",
            from:"chandanthakur5225@gmail.com",
            subject:"Result Test mail",
            message:"Hiiii!"
        )
    end
end
