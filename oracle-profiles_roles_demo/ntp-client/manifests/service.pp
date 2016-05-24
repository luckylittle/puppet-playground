#Author: Lucian Maly <lucian.maly@oracle.com>

class ntp::service {
service {'ntpd':
 ensure  => running,
 enable  => true,
 require => Package['ntp'],
 }
}
