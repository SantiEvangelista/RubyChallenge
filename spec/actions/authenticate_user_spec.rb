# spec/actions/authenticate_user_spec.rb
require_relative '../spec_helper'
require_relative '../../app/actions/authenticate_user'

RSpec.describe Actions::AuthenticateUser do
  describe ".call" do
    context "with valid credentials" do
      it "returns success and a JWT token" do
        result = Actions::AuthenticateUser.call("admin", "secret")
        expect(result[:success]).to be true
        expect(result[:token]).to be_a(String)
        expect(result[:token]).not_to be_empty
      end
    end

    context "with invalid credentials" do
      it "returns failure and an error message" do
        result = Actions::AuthenticateUser.call("wrong", "password")
        expect(result[:success]).to be false
        expect(result[:error]).to eq("Invalid credentials")
        expect(result[:token]).to be_nil
      end
    end
  end

  describe ".decode_token" do
    let(:valid_token) { JWT.encode({ user_id: 1, username: "admin", exp: Time.now.to_i + 3600 }, Actions::AuthenticateUser::SECRET_KEY, 'HS256') }
    let(:invalid_token) { "invalid.token.string" }
    let(:expired_token) { JWT.encode({ user_id: 1, username: "admin", exp: Time.now.to_i - 3600 }, Actions::AuthenticateUser::SECRET_KEY, 'HS256') }

    context "with a valid token" do
      it "decodes the token and returns the payload" do
        decoded = Actions::AuthenticateUser.decode_token(valid_token)
        expect(decoded).to be_an(Array)
        expect(decoded[0]['username']).to eq("admin")
        expect(decoded[0]['user_id']).to eq(1)
      end
    end

    context "with an invalid token" do
      it "returns nil" do
        decoded = Actions::AuthenticateUser.decode_token(invalid_token)
        expect(decoded).to be_nil
      end
    end

    context "with an expired token" do
      it "returns nil" do
        decoded = Actions::AuthenticateUser.decode_token(expired_token)
        expect(decoded).to be_nil
      end
    end
  end
end
