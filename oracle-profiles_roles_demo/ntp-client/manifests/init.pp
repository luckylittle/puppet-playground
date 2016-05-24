# == Class: ntp
#
# === Parameters
#
# === Variables
#
# === Examples
#
# === Authors
# Lucian Maly <lucian.maly@oracle.com>
#
# === Copyright
# Copyright 2016 Lucian Maly.
#
class ntp ($ntp_server = $ntp::params::ntp_server) inherits ntp::params {
 notify {"The ntp server is ${ntp_server}":}
 include ntp::package, ntp::file, ntp::service
}
