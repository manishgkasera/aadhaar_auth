module AadhaarAuth
  class Config
    class << self
      attr_accessor :api_version,
                    :asa_licence_key,
                    :public_certificate_path,
                    :digital_signature_path,
                    :digital_signature_pwd,
                    :ac, :lk, :sa, :tid, :udc


    end

    Config.api_version = '1.6'
    Config.asa_licence_key = 'MLTbKYcsgYMq1zgL3WMZYrnyvsarlljxpom2A-QTPc0Zud23shpnqPk'
    Config.lk = 'MKHmkuz-MgLYvA54PbwZdo9eC3D5y7SVozWwpNgEPysVqLs_aJgAVOI'

    keys_path = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'keys'))
    Config.public_certificate_path = File.join(keys_path, 'Auth_Staging.cer')

    Config.digital_signature_path = File.join(keys_path, 'public-may2012.p12')
    Config.digital_signature_pwd = 'public'

    Config.ac = 'public'
    Config.sa = 'public'
    Config.tid = 'public'
    Config.udc = '1122'
  end
end