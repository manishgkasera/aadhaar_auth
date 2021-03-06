require 'curb'
require 'aadhaar_auth/encrypter'
require 'aadhaar_auth/digital_signer'

module AadhaarAuth
  class Client
    attr_accessor :verbose
    attr_reader :aadhaar_no, :name, :email, :phone, :gender, :time,
             :encrypter, :digital_signer, :raw_response, :error_code

    def initialize(person_data)
      @aadhaar_no = person_data[:aadhaar_no].to_s
      @name = person_data[:name]
      @email = person_data[:email]
      @phone = person_data[:phone]
      @gender = person_data[:gender]
      @time = Time.now
      @encrypter = Encrypter.new
      @digital_signer = DigitalSigner.new
      @raw_response = nil
    end

    def valid?
      # should be exactly 12 digits
      if aadhaar_no !~ /^\d{12}$/
        return(false)
      end

      @raw_response = Curl::Easy.http_post(url, raw_request).body_str

      if verbose
        puts "URL: \n#{url}"
        puts "PID XML: \n#{pid_block()}"
        puts "Signed request: \n#{raw_request}"
        puts "Response: \n#{@raw_response}"
      end

      digital_signer.verify_signature(@raw_response) if Config.verify_response_signature

      auth_res = Nokogiri::XML(@raw_response).children.find{|c| c.name == 'AuthRes'}
      @error_code = auth_res.attributes['err'] ? auth_res.attributes['err'].value : nil

      ret = auth_res.attributes['ret'] ? auth_res.attributes['ret'].value : nil
      if ret && ret != ''
        return ret == 'y'
      end

      raise ResponseError.new(["Error :#{@error_code}", pid_block, raw_request, @raw_response].join("\n\n"))
    end

    def url
      @url ||= url = "http://auth.uidai.gov.in/#{Config.api_version}/public/#{aadhaar_no[0]}/#{aadhaar_no[1]}/#{Config.asa_licence_key}"
    end

    def raw_request
      @raw_request ||= digital_signer.sign(req_xml)
    end

    def req_xml
      nok = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |x|
        x.Auth(
                'uid' => aadhaar_no,
                'ac' => Config.ac,
                'lk' => Config.lk,
                'sa'=> Config.sa,
                'tid'=> Config.tid,
                'txn'=>"AuthDemoClient:public:#{time.to_i}",
                'ver'=> Config.api_version,
                'xmlns:ds'=>"http://www.w3.org/2000/09/xmldsig#",
                'xmlns'=>"http://www.uidai.gov.in/authentication/uid-auth-request/1.0") do
          x.Uses('bio'=>'n', 'otp'=>"n", 'pa'=>"n", 'pfa'=>"n", 'pi'=>"y", 'pin'=>"n")
          x.Meta('fdc'=>"NA", 'idc'=>"NA", 'lot'=>"P", 'lov' => "560094", 'pip' => "NA", 'udc'=> Config.udc)
          x.Skey('ci'=> skey_ci) do
            x.text(encrypter.encrypted_session_key)
          end
          x.Data('type' => "X") do
            x.text(encrypted_data)
          end
          x.Hmac(encrypter.calculate_hmac(pid_block))
          x['ds'].Signature do
            x['ds'].SignedInfo do
              x['ds'].CanonicalizationMethod('Algorithm' => "http://www.w3.org/2001/10/xml-exc-c14n#")
              x['ds'].SignatureMethod('Algorithm' => "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256")
              x['ds'].Reference('URI' => "") do
                x['ds'].Transforms do
                  x['ds'].Transform('Algorithm'=>"http://www.w3.org/2000/09/xmldsig#enveloped-signature")
                end
                x['ds'].DigestMethod('Algorithm'=>"http://www.w3.org/2001/04/xmlenc#sha256")
                x['ds'].DigestValue('')
              end
            end
            x['ds'].SignatureValue('')
            x['ds'].KeyInfo do
              x['ds'].X509Data do
                x['ds'].X509SubjectName(DigitalSigner.private_key_cert.subject.to_s)
                x['ds'].X509Certificate(DigitalSigner.private_key_cert_val)
              end
            end
          end
        end
      end
      nok.to_xml
    end

    def pid_block
      @pid_block ||= begin
        xml = Nokogiri::XML('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
        Nokogiri::XML::Builder.with(xml) do |x|
          x.Pid('ts' => time.strftime("%Y-%m-%dT%H:%M:%S"), 'xmlns:ns2' => 'http://www.uidai.gov.in/authentication/uid-auth-request-data/1.0') do
            x.parent.namespace = x.parent.namespace_definitions.find{|ns| ns.prefix == "ns2"}
            x.Demo do
              info = {'ms' => "E", 'mv' => "100", 'name' => name}
              info.merge!('gender' => gender) if gender
              info.merge!('phone' => phone) if phone
              info.merge!('email' => email) if email
              x.Pi(info)
            end
          end
        end.to_xml
      end
    end

    def encrypted_data
      @encrypted_data ||= begin
        Base64.encode64(encrypter.encrypt_using_session_key(pid_block))
      end
    end

    def skey_ci
      encrypter.public_cert.not_after.strftime('%Y%m%d')
    end

    class ResponseError < Exception; end
  end
end