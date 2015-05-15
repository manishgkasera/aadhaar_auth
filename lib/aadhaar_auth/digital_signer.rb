require 'xmldsig'

module AadhaarAuth
  class DigitalSigner

    def sign(xml)
      Xmldsig::SignedDocument.new(xml).sign(self.class.private_key)
    end

    def verify_signature(xml)
      if !Xmldsig::SignedDocument.new(xml).validate(Encrypter.public_cert)
        raise InvalidSignature.new("Invalid response signature")
      end
    end

    class << self
      def pkcs12
        @pkcs12 ||= OpenSSL::PKCS12.new(File.read(Config.digital_signature_path), Config.digital_signature_pwd)
      end

      def private_key
        @private_key ||= OpenSSL::PKey::RSA.new(pkcs12.key.to_s)
      end

      def private_key_cert
        @private_key_cert ||= OpenSSL::X509::Certificate.new(pkcs12.certificate.to_s)
      end

      def private_key_cert_val
        @private_key_cert_val ||= private_key_cert.to_s.sub(/^-----BEGIN CERTIFICATE-----\n/, '').sub(/-----END CERTIFICATE-----\n$/, '')
      end
    end

    class InvalidSignature < Exception; end
  end
end