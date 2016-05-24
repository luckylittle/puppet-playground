#Author: Lucian Maly <lucian.maly@oracle.com>

class ntp::package {
#Create a module that installs ntp and ensures it runs on reboot ('sudo chkconfig puppet on' or 'puppet resource service puppet ensure=running enable=true')
package { 'ntp':
 ensure  => installed,
 }
}
