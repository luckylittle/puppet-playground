# Lucian Maly <lucian.maly@oracle.com>

class profiles::infra {

#Hiera lookup
 $ntp_server=hiera(ntp_server)

#Configure NTP
class {'ntp':
  ntp_server => $ntp_server,
 }
}

