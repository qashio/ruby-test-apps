# frozen_string_literal: true

require 'jwt'

module JsonWebToken
  def self.secret_key
    Rails.application.secret_key_base
  end

  def self.encode(payload, exp = 48.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new decoded
  end
end