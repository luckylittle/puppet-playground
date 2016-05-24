#Author: Lucian Maly <lucian.maly@oracle.com>

class ntp::file {
#The ntp.conf should be a file template with all config options as variables in the params.pp file
  file { '/etc/ntp.conf':
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template('ntp/ntp.conf.erb'),
    notify  => Service['ntpd'],
    require => Package['ntp'],
  }
}
