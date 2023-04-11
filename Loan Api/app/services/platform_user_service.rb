class PlatformUserService

    attr_accessor :url

    def initialize
        @url = URI.parse("#{ENV['IAM_URI']}")
    end

    def get_user(entity_id, user_id)
        request = Net::HTTP::Get.new("#{url}/v2/service_api/entities/#{entity_id}/users/#{user_id}")
        request['source'] = "loans"
        request['Authorization'] = sign_payload({}, "loans")
        response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
            http.request(request)
        end
        unless response.code == '200'
            raise "Error"
        end
        json_response = JSON.parse(response.body)
        json_response['_json_params'] = response.body
        json_response
        # PlatformUsers.new(JSON.parse(response.body))
    end

    def get_all_users(entity_id)
        request = Net::HTTP::Get.new("#{url}/v2/service_api/entities/#{entity_id}/users")
        request['source'] = "loans"
        request['Authorization'] = sign_payload({}, "loans")
        response = Net::HTTP.start(url.hostname, url.port, req_options) do |http|
            http.request(request)
        end
        unless response.code == '200'
            raise "Error"
        end
        all_users = JSON.parse(response.body)["users"]
        users = []
        for user in all_users
            users << PlatformUsers.new(user)
        end
        users
    end

    def sign_payload(payload = {}, source_key = nil)
        payload['exp'] = Time.now.to_i + 5.minutes.to_i
        payload['source'] = source_key
        JWT.encode(payload, ENV["rbac_secret"], 'HS256')
    end

    def req_options
        { use_ssl: url.scheme == 'https' }
    end

end