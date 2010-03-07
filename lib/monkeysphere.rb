module Msva
  class Validator
    def self.reviewcert(params)
      unless params.is_a?(Hash)
        return({ :valid => false, :message => "provided query must be a hash"})
      end

      unless (params["pkc"] && ["x509der", "x509pem"].include?(params["pkc"]["type"]))
        return({ :valid => false, :message => "pkc not present or of not-understood type" })
      end

      data = params["pkc"]["data"]
      data = data.pack("C*") if data.kind_of?(Array)
      begin
        ssl_pkey = OpenSSL::X509::Certificate.new(data).public_key
      rescue
        return({ :valid => false, :message => "X509 certificate could not be parsed" })
      end

      unless ssl_pkey.is_a?(OpenSSL::PKey::RSA)
        return({ :valid => false, :message => "only RSA keys supported for now"})
      end

      uid = params["context"] + "://" + params["peer"]
      # FIXME: properly escape this shell command
      `monkeysphere u "#{uid}"`.lines do |line|
        proto, key = line.strip.split(' ', 2)
        unless proto == "ssh-rsa"
          $stderr.puts "WARNING: non-rsa key type #{proto} found!"
          next
        end

        monkey_pkey = OpenSshPubKey::RSA.new(key)
        if (monkey_pkey.n == ssl_pkey.n) && (monkey_pkey.e == ssl_pkey.e)
          return({ :valid => true, :message => "#{uid} validated with Monkeysphere" })
        end
      end
      
      { :valid => false, :message => "No valid matching OpenPGP keys found for #{uid}" }
    end
  end
end
