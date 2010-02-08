Monkeysphere Validation Agent
=============================

This is a Ruby version of the [Monkeysphere](http://web.monkeysphere.info/)
Validation Agent.

Prerequisites
-------------

To run msva-rb, you need to install the libraries upon which it
depends. You can do so using either [Rubygems](http://rubygems.org) or
[Debian](http://www.debian.org/) packaging. To install the
prerequisites using Rubygems, make sure that you have, [the
Monkeysphere](http://web.monkeysphere.info/), Ruby (including the ruby
OpenSSL libraries), and Rubygems installed, then do

    sudo gem install json sinatra thin

To install the prerequisites on Debian, do

    sudo aptitude install monkeysphere ruby libopenssl-ruby libsinatra-ruby libjson-ruby thin

### Additional Prerequisites for Running Tests

If you want to be able to run the test suite, you will need some
additional packages:

    sudo gem install rake rspec mocha rack-test

or

    sudo aptitude install rake librspec-ruby libmocha-ruby

Unfortunately, `rack-test` is not yet available in Debian, so you will
need to install it some other way: either from
[upstream](http://github.com/brynary/rack-test) or from a gem.


Running the MSVA
----------------

To launch the MSVA, simply do

    ./run.rb

from within the `msva-ruby` directory. This will start the agent
listening (only to connections from localhost) on port 8901.

You can then visit <http://localhost:8901/> to validate some keys or use
[xul-ext-monkeysphere](http://github.com/mlc/xul-ext-monkeyspehere) to
validate TLS keys from within your web browser.

### Running the test suite

Would you like to run the test suite? Of course you would. Just do

    rake spec

Warning
-------

This is all experimental software under active development. Things may
not work, and things which once worked may break.


License
-------

The Monkeysphere Validation Agent, Ruby version, is Copyright © 2010
Michael Castleman.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
