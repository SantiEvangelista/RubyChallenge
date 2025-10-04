require "sinatra"
require "json"

set :port, 8080

post "/login" do
  data = JSON.parse(request.body.read) rescue {}
  username = data["username"]
  password = data["password"]

  if username == "admin" && password == "secret"
    status 200
    { access: "granted" }.to_json
  else
    status 401
    { access: "denied" }.to_json
  end
end
