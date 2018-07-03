require 'base64'
require 'openssl'

class ClassmarkerController < ApplicationController

  #no need for CSRF
  skip_before_action :verify_authenticity_token

  before_action :verify_hmac_signature
  before_action :verify_payload_json

  def webhook
    save_webhook_data request.raw_post
    head :ok
  end

  private

  class InvalidPayloadError < StandardError
    def initialize
      super 'Payload must be valid JSON'
    end
  end

  class InvalidHMACError < StandardError
    def initialize
      super 'Invalid HMAC signature'
    end
  end

  def verify_hmac_signature
    raise InvalidHMACError unless hmac_header_valid?
  end

  def verify_payload_json
    raise InvalidPayloadError unless payload_json?
  end

  def save_webhook_data(data)
    # Save results in your database.
    # Important: Do not use a script that will take a long time to respond.
  end

  def hmac_header_valid?
    headerVal = request.headers['HTTP_X_CLASSMARKER_HMAC_SHA256']
    return false unless headerVal.present?

    expected = headerVal.split(/,/).first
    actual = calculate_signature(request.raw_post)

    ActiveSupport::SecurityUtils.secure_compare(actual, expected)
  end


  def calculate_signature(data)
    secret = "YOUR_CLASSMARKER_WEBHOOK_SECRET_PHRASE"

    digest = OpenSSL::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, secret, data)).strip
  end

  def payload_json?
    JSON.parse(request.raw_post)
    true
  rescue
    false
  end

  def timestamped_filename(extension = '.json')
    Time.now.strftime('%Y-%m-%d_%H-%M-%S') + extension
  end
end
