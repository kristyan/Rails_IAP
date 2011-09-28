 # Provides functionality to communicate with Apples in app purchases receipt verification API
 class IosInAppPurchasesVerifier
  include HTTParty
  
  DEFAULT_APPLE_RECEIPT_VERIFY_URL = 'https://sandbox.itunes.apple.com/verifyReceipt'
  
  attr_accessor :shared_secret
  
  def initialize(shared_secret, base_uri=DEFAULT_APPLE_RECEIPT_VERIFY_URL)
    self.class.base_uri base_uri
    self.shared_secret = shared_secret
  end  
  
  # Sends an auto-renewable receipt to apple for verification and returns a JSON response:
  # See http://developer.apple.com/library/ios/#documentation/NetworkingInternet/Conceptual/StoreKitGuide/RenewableSubscriptions/RenewableSubscriptions.html#//apple_ref/doc/uid/TP40008267-CH4-SW2
  #
  # {
  #
  #    "status" : 0,
  #
  #    "receipt" : { ... }
  #
  #    "latest_receipt" : "(base-64 encoded receipt)"
  #
  #    "latest_receipt_info" : { ... }
  #
  # }
  #
  # App Store status codes
  # 0 - Success, the recept data is also returned
  # 21000 The App Store could not read the JSON object you provided.
  # 21002 The data in the receipt-data property was malformed.
  # 21003 The receipt could not be authenticated.
  # 21004 The shared secret you provided does not match the shared secret on file for your account.
  # 21005 The receipt server is not currently available.
  # 21006 This receipt is valid but the subscription has expired. 
  #       When this status code is returned, the receipt data is also decoded and returned as part of the response.
  # 21007 This receipt is a sandbox receipt, but it was sent to the production service for verification.
  # 21008 This receipt is a production receipt, but it was sent to the sandbox service for verification.
  #
  # Raises an exception if a connection error occurs
  #
  def verify_auto_renewable_receipt(base64_receipt)
    self.class.headers 'Content-Type' => 'application/json'
    payload = {'receipt-data' => base64_receipt, :password => shared_secret}.to_json
    response = self.class.post('/', :body => payload)
    if response.code != 200
      raise "Error Verifying Receipt, Got http response code: #{response.code}"
    end 
    # I was hoping that parsed_response would return a Hash, but it returns a String
    # so I convert the JSON string to a Hash
    JSON.parse response.parsed_response
  end

end