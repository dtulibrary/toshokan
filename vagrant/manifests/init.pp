include vagrant_hosts

class {'toshokan': 
  rails_env  => 'unstable',
  conf_set   => 'vagrant',
  vhost_name => 'toshokan.vagrant.vm',
}
