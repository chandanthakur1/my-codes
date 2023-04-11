class WelcomeMailer < ApplicationMailer
    def send_welcome_mail

        mail(to: 'thakurchandan4562@gmail.com', subject: "You got a new order!")
    end
end
