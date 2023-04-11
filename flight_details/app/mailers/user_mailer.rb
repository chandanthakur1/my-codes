class UserMailer < ApplicationMailer
    default from: 'thakurchandan2640@gmaiil.com'


    def welcome_email
        @greeting = "Hi Hello"
        mail(to: 'thakurchandan4562@gmail.com')
    end
end
