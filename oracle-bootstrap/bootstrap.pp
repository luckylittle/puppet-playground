#Author: Lucian Maly <lucian.maly@oracle.com>

#Install git package
package {'git':
 ensure => installed,
}

#Make sure there is .ssh subdirectory of Puppet
file {'/var/lib/puppet/.ssh':
 ensure => directory,
 owner => 'puppet',
 group => 'puppet',
}

#Have a private key in the above directory
file {'/var/lib/puppet/.ssh/id_rsa':
 content    => "
-----BEGIN RSA PRIVATE KEY-----
<<REMOVED_FOR_SECURITY_REASONS>>
-----END RSA PRIVATE KEY-----
",
 mode    => 0600,
 require => File['/var/lib/puppet/.ssh'],
}

#Make sure the SSH works between the node and Git server
exec {'download git host key':
 command => 'sudo -u puppet ssh-keyscan gitlab.com >> /var/lib/puppet/.ssh/known_hosts',
 path    => '/usr/bin:/usr/sbin:/bin:/sbin',
 unless  => 'grep gitlab.com /var/lib/puppet/.ssh/known_hosts',
 require => File['/var/lib/puppet/.ssh'],
}

#Prepare directory where we'll clone the repo
file {'/usr/share/puppet/modules':
 ensure => directory,
}

#Clone from the Git server to /etc/puppet/git_repository
exec {'clone repository onto the new machine':
 command => 'sudo -u puppet git clone git@gitlab.com:pdit_cloud_automation_grp_ww/ntp-client.git /usr/share/puppet/modules',
 path    => '/usr/bin:/usr/sbin:/bin:/sbin',
 require => [Package['git'],File['/var/lib/puppet/.ssh/id_rsa'],Exec['download pdit-tools.oracleoutsourcing.com host key']],
 unless  => 'test -f /usr/share/puppet/modules/.git/config',
}
