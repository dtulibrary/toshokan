include vagrant_hosts

class {'apache2':
  disable_default_vhost => true,
}

class {'toshokan':
  rails_env       => 'unstable',
  conf_set        => 'vagrant',
  vhost_name      => 'toshokan.vagrant.vm',
  bundler_version => 'cvt_provided',
}
