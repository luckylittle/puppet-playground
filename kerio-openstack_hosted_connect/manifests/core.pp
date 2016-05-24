# maly (c) 2013
# This document serves as an example of how to deploy
# basic multi-node openstack environments.


node base {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"

  # /etc/hosts entries for the controller nodes
  host { $::controller_hostname:
	  ip => $::controller_node_internal
  }

	#fix for Ubuntu bug https://bugs.launchpad.net/ubuntu/+source/puppet/+bug/995719 - Puppet 2.7.11 randomly hangs on Ubuntu
  file { '/usr/lib/ruby/1.8/puppet/util/instrumentation/listeners/process_name.rb':
    ensure => absent,
  }
 
  file { '/etc/apt/apt.conf.d/00no_pipelining':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    content => 'Acquire::http::Pipeline-Depth "0";',
    notify => Exec[apt_update]
  }

  file { "/usr/local/sbin/last_puppet_run.rb":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/last_puppet_run.rb"
  }
  file { "/etc/sudoers.d/zabbix_sudoers":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0440',
    	source	=> "puppet:///files/zabbix_sudoers"
  }
	file { "/etc/zabbix/zabbix_agentd.d/zabbix_agent_puppet.conf":
            owner 	=> zabbix,
            group 	=> zabbix,
            mode 	=> 644,
            content => template("zabbix/zabbix_agent_puppet.conf"),
			notify	=> Service['zabbix-agent'],
            require => Package["zabbix-agent"];
	} 
  	
  	cron { puppet-agent:
  			command => "/usr/bin/puppet agent -t",
  			user    => root,
  			hour    => '*',
  			minute  => fqdn_rand(60),
  			ensure => present,
	}
}

#################################################################
#
#  Openstack nodes configuration (SSH keys, files, Zabbix, NTP etc.
#
#################################################################

node os_base inherits base {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"
  class { ntp:
	  servers		=> ["${build_node_fqdn} iburst"],
	  ensure 		=> running,
	  autoupdate 	=> true,
  }

  	# add staff ssh access keys
	ssh_authorized_key { 'sshkey-pd':
  		name     => "root@domain.com",
  		ensure   => present,
		key		 => "<<KEY REMOVED FOR PRIVACY REASONS>>",
		type     => "ssh-rsa",
  		user     => root
  	}
  class { 'zabbix::agent':
  		zabbix_server => $::cobbler_node_ip
  }

    file { "/etc/zabbix/zabbix_agentd.d/zabbix_drive_stats.conf":
            owner 	=> zabbix,
            group 	=> zabbix,
            mode 	=> 644,
            content => template("zabbix/zabbix_drive_stats.conf"),
			notify	=> Service['zabbix-agent'],
            require => Package["zabbix-agent"];
	}
    file { "/etc/zabbix/zabbix_agentd.d/zabbix_megaraid_stats.conf":
            owner 	=> zabbix,
            group 	=> zabbix,
            mode 	=> 644,
            content => template("zabbix/zabbix_megaraid_stats.conf"),
			notify	=> Service['zabbix-agent'],
            require => Package["zabbix-agent"];
	}
	file { "/usr/local/sbin/discovery_disk.pl":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/discovery_disk.pl"
    }
	file { "/usr/local/sbin/megaraid_discovery_pd.sh":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/megaraid_discovery_pd.sh"
    }
	file { "/usr/local/sbin/megaraid_discovery_ld.sh":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/megaraid_discovery_ld.sh"
    }
	package{"gawk" : 
	   ensure => installed
  }
    
}
#################################################################
#
#  OS Instances configuration (SSH keys, files, Zabbix, NTP etc.
#
#################################################################

node os_instance inherits base {
  $build_node_fqdn = "${::build_node_name}.${::domain_name}"
  class { ntp:
	  servers		=> ["${build_node_fqdn} iburst"],
	  ensure 		=> running,
	  autoupdate 	=> true,
  }

	class { 'apt':
  		proxy_host           => $::cobbler_node_ip,
  		proxy_port           => '3142',
	}
  class { 'zabbix::agent':
  		zabbix_server => $::zabbix_proxy_ip
  }
  	# add general ssh access key
	    ssh_authorized_key { 'general-sshkey':
  		name     => "hostmaster@domain.com",
  		ensure   => present,
  		key      => "<<KEY REMOVED FOR PRIVACY REASONS>>",
		type     => "ssh-rsa",
  		user     => root
  	}

  	file { "/usr/local/bin/config-merge.py":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/config-merge.py"
    }
    
    package{"fail2ban" : 
	   ensure => installed
  	}

}

class node-firewall ( $restart_services ) {

	#create predefined set of iptables rules
    file { "/etc/iptables.up.rules":
            owner 	=> root,
            group 	=> root,
            mode 	=> 644,
            content => template("iptables.up.rules.erb"),
            notify => Exec["restart-firewall"]
	}
	exec { "restart-firewall":
		command 	=> "/sbin/iptables-restore < /etc/iptables.up.rules",
			path     => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin" ],
			notify  => $restart_services,
			refreshonly => true
	}
	file { "/etc/network/if-pre-up.d/iptables":
            owner 	=> root,
            group 	=> root,
            mode 	=> 755,
            content => "#!/bin/bash\n/sbin/iptables-restore < /etc/iptables.up.rules",
	}
	
}

########### Definition of the Build Node #######################
#
# Definition of this node should match the name assigned to the build node in your deployment.
# In this example we are using build-node, you dont need to use the FQDN.
#

node master-node inherits "cobbler-node" {

  $build_node_fqdn = "${::build_node_name}.${::domain_name}"

  host { $build_node_fqdn:
	  ip => $::cobbler_node_ip
  }

  host { $::build_node_name:
	  ip => $::cobbler_node_ip
  }

  class {'apache':
  	purge_vdir => false
   }
  class {'cobbler::web': }
  
  class{'ceph::repo': }
	
  package{"ceph-common" : 
	   ensure => installed,
	   require => Class["ceph::repo"]
  }
  
  package { "ceph-deploy": 
		ensure => "present",
		require => Class["ceph::repo"]
  }
  
  class { ntp:
		servers => $::ntp_servers,
		ensure => running,
		autoupdate => true,
  }

  class { zabbix::proxy: 
  		zabbix_server 		 => $::zabbix_server,
  		zabbix_proxy_db_pass => "mPiHwOV3TWfaxlFNmn9K",
		zabbix_proxy_name    => $::zabbix_proxy_name
  }
  
    # set up a local apt cache.  Eventually this may become a local mirror/repo instead
  class { apt-cacher-ng:
        proxy           => $::proxy,
        avoid_if_range  => true, # Some proxies have issues with range headers
                             # this stops us attempting to use them
                             # marginally less efficient with other proxies
  }

  # set the right local puppet environment up.  This builds puppetmaster with storedconfigs (a nd a local mysql instance)
  class { puppet:
	  run_master 		=> true,
	  puppetmaster_address 	=> $build_node_fqdn, 
	  certname 		=> $build_node_fqdn,
	  mysql_password 		=> 'ubuntu',
  }<-

  file {'/etc/puppet/files':
	  ensure => directory,
	  owner => 'root',
	  group => 'root',
	  mode => '0755',
  }

  file {'/etc/puppet/fileserver.conf':
	  ensure => file,
	  owner => 'root',
	  group => 'root',
	  mode => '0644',
	  content => '

# This file consists of arbitrarily named sections/modules
# defining where files are served from and to whom

# Define a section "files"
# Adapt the allow/deny settings to your needs. Order
# for allow/deny does not matter, allow always takes precedence
# over deny
[files]
  path /etc/puppet/files
  allow *
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24

[plugins]
#  allow *.example.com
#  deny *.evil.example.com
#  allow 192.168.0.0/24
',
    }
    file { "/root/.ssh":
    	ensure => directory,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0700',
    }
    
    file { "/root/.ssh/id_rsa":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0600',
    	content	=> '-----BEGIN RSA PRIVATE KEY-----
     <<KEY REMOVED FOR PRIVACY REASONS>>
-----END RSA PRIVATE KEY-----
',
	require => File['/root/.ssh']
    }
    
	file { "/root/.ssh/config":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0600',
    	require => File["/root/.ssh"]
    }

}

