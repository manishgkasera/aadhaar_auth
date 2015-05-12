module AadhaarAuth
  class Encrypter
    ENC_ALGO = 'AES-256-ECB'

    def session_key
      @session_key ||= begin
        aes = OpenSSL::Cipher.new(ENC_ALGO)
        aes.encrypt
        aes.random_key
      end
    end

    def encrypted_session_key
      @encrypted_session_key ||= begin
        public_key = public_cert.public_key
        Base64.encode64(public_key.public_encrypt(session_key))
      end
    end

    def encrypt_using_session_key(data)
      aes = OpenSSL::Cipher.new(ENC_ALGO)
      aes.encrypt
      aes.key = session_key
      (aes.update(data) + aes.final)
    end

    def calculate_hmac(data)
      Base64.encode64(encrypt_using_session_key(Digest::SHA256.digest(data)))
    end

    def public_cert
      self.class.public_cert
    end

    class << self
      def public_cert
        @public_cert ||= OpenSSL::X509::Certificate.new(File.read(Config.public_certificate_path))
      end
    end
  end
end