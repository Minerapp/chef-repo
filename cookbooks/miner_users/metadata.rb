name             'miner_users'
maintainer       'Miner Labs'
maintainer_email 'mike@miner.com'
license          'All rights reserved'
description      'Installs/Configures miner_users'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.0'
depends 'users'
depends 'sudo'
depends 'bashrc', "~> 2.0"
