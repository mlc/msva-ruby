# Copyright © 2010 Michael Castleman <m@mlcastle.net>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'base64'
require 'openssl'

# Class to read and write OpenSSH-style public keys
# currently only RSA keys are supported.
module OpenSshPubKey
  class RSA
    attr_accessor :n, :e

    def initialize(keytxt = nil)
      return if keytxt.nil?

      keytxt = Base64.decode64(keytxt)

      raise "not an openssh rsa pubkey" unless keytxt[0..10] == "\000\000\000\007ssh-rsa"
      offset, self.e = OpenSshPubKey.get_mpi(keytxt, 11)
      offset, self.n = OpenSshPubKey.get_mpi(keytxt, offset)
    end

    def to_s
      Base64.encode64(OpenSSL::BN.new("ssh-rsa", 2).to_s(0) + e.to_s(0) + n.to_s(0)).gsub("\n", '')
    end
  end

  class DSS
    attr_accessor :p, :q, :g, :pub_key

    def initialize(keytxt = nil)
      return if keytxt.nil?

      keytxt = Base64.decode64(keytxt)

      raise "not an openssh dss pubkey" unless keytxt[0..10] == "\000\000\000\007ssh-dss"

      offset, self.p = OpenSshPubKey.get_mpi(keytxt, 11)
      offset, self.q = OpenSshPubKey.get_mpi(keytxt, offset)
      offset, self.g = OpenSshPubKey.get_mpi(keytxt, offset)
      offset, self.pub_key = OpenSshPubKey.get_mpi(keytxt, offset)
    end

    def to_s
      components = [OpenSSL::BN.new("ssh-dss", 2), p, q, g, pub_key]
      Base64.encode64(components.map{|comp| comp.to_s(0)}.join).gsub("\n", '')
    end
  end

  def self.parse(key)
    case key[0..7]
    when "ssh-rsa "
      OpenSshPubKey::RSA.new(key[8..-1])
    when "ssh-dss "
      OpenSshPubKey::DSS.new(key[8..-1])
    end
  end

  def self.get_mpi(str, offset)
    len = str[offset..(offset+3)].unpack("N")[0]
    [offset + 4 + len, OpenSSL::BN.new(str[(offset+4)...(offset+4+len)], 2)]
  end
end
