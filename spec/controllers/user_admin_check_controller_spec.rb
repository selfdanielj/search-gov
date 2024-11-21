require 'spec_helper'

describe UserAdminCheckController do
  describe "test controller #admin_check" do   
    [["User", true], [nil, false]].each do |query_result,expected_is_admin|
      it "returns a valid response on an admin check where is_admin = #{expected_is_admin}" do
        allow(User).to receive(:find_by).and_return(query_result)
        post :admin_check, params: { email: "test-user@example.com" }
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq("application/json; charset=utf-8")
        expect(response.parsed_body).to have_key("email")
        expect(response.parsed_body).to have_key("is_admin")
        expect(response.parsed_body[:email]).to eq "test-user@example.com"
        expect(response.parsed_body[:is_admin]).to eq expected_is_admin
      end
    end

    it "returns error status if email parameter is missing" do
      post :admin_check, params: { full_name: "John Doe" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.parsed_body[:error]).to eq "An 'email' parameter and value are required."
    end

    it "returns error status if email parameter is blank" do
      post :admin_check, params: { email: "" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.content_type).to eq("application/json; charset=utf-8")
      expect(response.parsed_body[:error]).to eq "An 'email' parameter and value are required."
    end

  end
end
