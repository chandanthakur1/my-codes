class PlatformUsers

    attr_accessor :name, :email, :notification_channels, :email_verified, :id, :auth0_user_id, :token, :expiry, 
    :invalidate_all_token_at, :terms_and_conditions_accepted, :user_id, :context, :channels, :username
    
    
    def initialize(json_payload)
        @user_id = json_payload["ca_user_id"]
        @name = json_payload["name"]
        @email = json_payload["email"]
        @notification_channels = json_payload["notification_channels"]
        @email_verified = json_payload["email_verified"]
        @id = json_payload["id"]
        @auth0_user_id = json_payload["auth0_user_id"]
        @token = json_payload["token"]
        @expiry = json_payload["expiry"]
        @invalidate_all_token_at = json_payload["invalidate_all_token_at"]
        @terms_and_conditions_accepted = json_payload["terms_and_conditions_accepted"]
        @context = json_payload["context"]
        @channels = json_payload["channels"]
        @username = json_payload["username"]
    end
end