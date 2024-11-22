# frozen_string_literal: true

class UserAdminCheckController < ApplicationController
  # Performs a admin check on a given email address.  `Returns 'is_admin': true` for
  # if a match on email is found and the user is an affiliate admin.

  skip_before_action :verify_authenticity_token
  wrap_parameters false

  def admin_check
    email = admin_check_params[:email]
    if email.nil? || email.blank?
      render json: { error: "An 'email' parameter and value are required." }, status: :unprocessable_entity
    else
      user = User.find_by(email:, is_affiliate_admin: true)
      render json: { email:, is_admin: user ? false : true }, status: :ok
    end
  end

  private

  def admin_check_params
    params.permit(:email)
  end
end
