class ResultMailer < ApplicationMailer
    def send_result_mail(state, expenditure)
        @state = state
        @expenditure = expenditure
        mail(
            to:"thakurchandan4562@gmail.com",
            from:"chandanthakur5225@gmail.com",
            subject:"Result Test mail",
            message:"Hiiii!"
        )
    end
end
