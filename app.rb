require "sinatra"
require "json"
require "dotenv/load"
require_relative "./app/actions/authenticate_user"

set :port, 8080

# Helper to authenticate JWT tokens
def authenticate_token
  halt 401, { message: "No token provided" }.to_json unless request.env["HTTP_AUTHORIZATION"]
  token = request.env["HTTP_AUTHORIZATION"].split(" ").last
  decoded_token = Actions::AuthenticateUser.decode_token(token)
  halt 401, { message: "Invalid token" }.to_json unless decoded_token
  @current_user = decoded_token[0]['username']
end

#Ruta Login
post "/login" do
  content_type :json
  data = JSON.parse(request.body.read) rescue {}
  username = data["username"]
  password = data["password"]

  result = Actions::AuthenticateUser.call(username, password)

  if result[:success]
    status 200
    { access: "granted", token: result[:token] }.to_json
  else
    status 401
    { access: "denied", error: result[:error] }.to_json
  end
end

#Ruta Test Auth (Valida el token y retorna el usuario autenticado)
get "/test_auth" do
  authenticate_token
  content_type :json
  status 200
  { message: "Welcome, #{@current_user}! You are authenticated." }.to_json
end



