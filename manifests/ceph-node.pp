# maly (c) 2013
class ceph-node (){

	class{'ceph::repo': }
	
	package{"ceph" : 
	   ensure => installed,
	   require => Class["ceph::repo"]
	}
	
	user { "ceph":
  		ensure     => "present",
		shell      => '/bin/bash',
  		managehome => true,
  	}
	
	file { "/etc/sudoers.d/ceph":
    	ensure  => "present",
    	content => "#Created and maitained by Puppet\nceph ALL = (root) NOPASSWD:ALL\n",
    	mode    => 0440,
	}
	ssh_authorized_key { "ceph-authorized_key":
		ensure 	=> "present",
		key		=> "<<KEY REMOVED FOR PRIVACY REASONS>>",
		name	=> "ceph@node",
		type	=> "ssh-rsa",
		user	=> "ceph"
	}

   	file { "/usr/local/sbin/ceph-status.sh":
    	ensure => file,
    	owner	=> 'root',
    	group	=> 'root',
    	mode	=> '0755',
    	source	=> "puppet:///files/ceph-status.sh"
    }
    file { "/etc/zabbix/zabbix_agentd.d/zabbix_agent_ceph_plugin.conf":
            owner 	=> zabbix,
            group 	=> zabbix,
            mode 	=> 644,
            content => template("zabbix/zabbix_agent_ceph_plugin.conf"),
			notify	=> Service['zabbix-agent'],
            require => Package["zabbix-agent"];
	}    
	package{"bc" : 
	   ensure => installed
  }
}