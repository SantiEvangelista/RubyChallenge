require "sinatra"
require "json"
require "dotenv/load"
require_relative "./app/actions/authenticate_user"
require_relative "./app/actions/list_products"
require_relative "./app/actions/create_product"
require_relative "./app/actions/show_product"

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

# ---- Productos ----

# Ver productos
get "/products" do
  authenticate_token
  content_type :json
  status 200
  { products: Actions::ListProducts.call }.to_json
end 

#Ruta de creación de productos
post "/products" do
  authenticate_token
  content_type :json
  status 200
  { product: Actions::CreateProduct.call(JSON.parse(request.body.read)) }.to_json
end

# Ver producto por ID
get "/products/:id" do
  authenticate_token
  content_type :json
  product = Actions::ShowProduct.call(params[:id])
  if product
    status 200
    { product: product }.to_json
  else
    status 404
    { message: "Product not found" }.to_json
  end
end

