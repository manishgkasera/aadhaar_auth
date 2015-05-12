# AadhaarAuth

Aadhaar Auth API v.1.6 ruby port

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aadhaar_auth'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aadhaar_auth

## Usage
```ruby
c = AadhaarAuth::Client.new(:aadhaar_no => '999999990019', :name => 'Shivshankar Choudhury')
c.valid? #true/false
```
there is also a verbose mode which prints the request/response on STDOUT
```ruby
c.verbose = true
```
## Configuration

By default test credentials are used, if you want to deploy it to production, use the confugurator as below

options available
* api_version
* asa_licence_key
* public_certificate_path
* digital_signature_path
* digital_signature_pwd
* ac
* lk
* sa
* tid
* udc

set them as
```ruby
AadhaarAuth::Config.asa_licence_key = "hfjsfdGJgGJghJGHJGJGHGFBJIG"
AadhaarAuth::Config.public_certificate_path = "/tmp/Auth_Staging.cer"
AadhaarAuth::Config.digital_signature_path = "/tmp/public-may2012.p12"
```

## API Doc
Aadhaar api documentation is available [here](https://developer.uidai.gov.in/site/book/export/html/18)

## Contributing

1. Fork it ( https://github.com/[my-github-username]/aadhaar_auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
