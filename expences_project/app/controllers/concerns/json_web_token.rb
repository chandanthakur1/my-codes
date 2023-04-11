require "jwt"

module JsonWebToken 
    extend ActiveSupport::Concern

    SECRET = Rails.application.secret_key_base 

    def jwt_encode(payload, exp = 1.day.from_now)
        payload[:exp] = exp.to_i
        JWT.encode(payload,SECRET)
    end
    def jwt_decode(token)
        decoded = JWT.decode(token,SECRET)[0]
        HashWithIndifferentAccess.new decoded
    end

    def current_active_user
        header = request.headers["Authorization"]
        unless header
            return render json: {message: "Not authorized"}
        end
        token = request.headers["Authorization"].split(" ").last
        jwt_data = jwt_decode(token)
        puts jwt_data
        userid = jwt_data[:user_id][:$oid]
        
        return Employee.find(userid)
    end

end