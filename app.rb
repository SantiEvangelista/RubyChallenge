require "sinatra"
require "sinatra/json"
require "json"
require "dotenv/load"
require_relative "./app/actions/authenticate_user"
require_relative "./app/actions/list_products"
require_relative "./app/actions/create_product"
require_relative "./app/actions/show_product"
require_relative "./app/actions/get_job_status"

set :port, 8080

# Configurar archivos estáticos
set :public_folder, File.dirname(__FILE__) + '/public'
set :static, true

# ---- Archivos estáticos con headers de caché ----

# openapi.yaml - NO debe cachearse
get '/openapi.yaml' do
  content_type 'application/x-yaml'
  cache_control :no_cache, :no_store, :must_revalidate
  headers 'Pragma' => 'no-cache', 'Expires' => '0'
  send_file File.join(settings.public_folder, 'openapi.yaml')
end

# AUTHORS - debe cachearse por 24 horas
get '/AUTHORS' do
  content_type 'text/plain'
  cache_control :public, max_age: 86400  # 86400 segundos = 24 horas
  send_file File.join(settings.public_folder, 'AUTHORS')
end

# Interfaz visual para la documentación en la raiz
get '/' do
  content_type 'text/html'
  erb :swagger_ui
end

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

#Ruta de creación de productos (asíncrona)
post "/products" do
  authenticate_token
  content_type :json
  
  # Validar que el body no esté vacío
  body_content = request.body.read
  if body_content.nil? || body_content.strip.empty?
    status 400
    return { success: false, error: "Request body cannot be empty" }.to_json
  end
  
  # Parsear el body JSON
  begin
    product_params = JSON.parse(body_content)
  rescue JSON::ParserError => e
    status 400
    return { success: false, error: "Invalid JSON format: #{e.message}" }.to_json
  end
  
  # Obtener delay del query parameter (opcional)
  delay = params[:delay]&.to_i || 5
  
  result = Actions::CreateProduct.call(product_params, delay)
  
  if result[:success]
    status 202 # Accepted - para operaciones asíncronas
    result.to_json
  else
    status 400
    result.to_json
  end
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

# Ver estado de un job asíncrono
get "/products/jobs/:job_id" do
  authenticate_token
  content_type :json
  
  result = Actions::GetJobStatus.call(params[:job_id])
  
  if result[:error]
    status 404
    result.to_json
  else
    status 200
    result.to_json
  end
end

