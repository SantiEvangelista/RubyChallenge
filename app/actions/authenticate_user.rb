# app/actions/authenticate_user.rb
require 'jwt'

module Actions
  class AuthenticateUser
    SECRET_KEY = ENV['JWT_SECRET'] || 'RubyChallenge'

    def self.call(username, password)
      if username == "admin" && password == "secret"
        token = JWT.encode({ user_id: 1, username: username, exp: Time.now.to_i + 3600 }, SECRET_KEY, 'HS256')
        { success: true, token: token }
      else
        { success: false, error: "Invalid credentials" }
      end
    end

    def self.decode_token(token)
      JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
    rescue JWT::DecodeError
      nil
    end
  end
end
