# maly (c) 2013
# A node definition for cobbler. This defines an item in Cobbler config representing a server to be deployed
# it must be followed by cobbler::node::interface to define server's interfaces

define cobbler_node(
	$ip, 
	$gateway = $cobbler::node_gateway,
	$power_address = undef, 
	$power_id = undef,
	$power_user = 'admin', 
	$power_password = 'password',
	$power_type = 'ipmitool',
	$preseed = '/etc/cobbler/preseeds/preseed-compute' ) 
{
	cobbler::node { $name:
			ip 			       => $ip,
			gateway		   	 => $gateway,
    	power_address  => $power_address,
    	power_user     => $power_user,
    	power_password => $power_password,
    	power_type     => $power_type,
    	power_id       => $power_id,
			profile        => "precise-x86_64",
    	domain         => $::domain_name,
    	preseed        => $preseed,
  	}
  	
  	## if we're defining new CEPH node, we should add some lines into .ssh/options so we can
  	## connect from build-node directly as user "ceph" via SSH without providing username
  	# like:
  	# Host ceph1
  	# Hostname ceph1.domain.local
  	#	User ceph
  	##
  	
  	if $name =~ /^ceph\d+/ {
  		
  		$config_file = "/root/.ssh/config"	
  		exec { "ssh-config-${name}":
			command 	=> "echo \"Host ${name}
      Hostname ${name}.${::domain_name}
      User ceph
\" >> ${config_file}",
			path     => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin" ],
			onlyif 		=> "test `grep -c ${name} ${config_file}` -eq 0",
			require		=> File["${config_file}"]
  		}
  	}
}

define ubuntu_preseed(
	$template = "preseed.erb",
	$packages = "openssh-server vim mc vlan lvm2 ntp puppet ifenslave",
	$diskpart = [$::install_drive]
)
{
	if ($::ipv6_ra == "") {
  		$ra='0'
	} else {
  		$ra = $::ipv6_ra 
	}
	
	if ($::interface_bonding == 'true'){
  		$bonding = "echo 'bonding' >> /target/etc/modules"
	} else {
  		$bonding = 'echo "no bonding configured"'
	}
 
####### Shared Variables from Site.pp #######
	$cobbler_node_fqdn 	        = "${::build_node_name}.${::domain_name}"

	cobbler::ubuntu::preseed { $name:
  		template					=> $template,
  		admin_user 				=> $::admin_user,
  		password_crypted 	=> $::password_crypted,
  		packages 					=> $packages,
  		ntp_server 				=> $::build_node_fqdn,
  		proxy 						=> $::cobbler_proxy,
  		expert_disk 			=> true,
  		diskpart 					=> $diskpart,
  		boot_disk 				=> $::install_drive,
  		late_command 			=> sprintf('sed -e "/logdir/ a pluginsync=true" -i /target/etc/puppet/puppet.conf ; \
sed -e "/logdir/ a server=%s" -i /target/etc/puppet/puppet.conf ; \
echo "dummy" >> /target/etc/modules ; \
%s ; \
echo "net.ipv6.conf.default.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.default.accept_ra=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.autoconf=%s" >> /target/etc/sysctl.conf ; \
echo "net.ipv6.conf.all.accept_ra=%s" >> /target/etc/sysctl.conf ;\
', $cobbler_node_fqdn, $bonding,
   $ra,$ra,$ra,$ra),
 }
}

node /cobbler-node/ inherits "base" {

####### Generate preseed file(s) #######
ubuntu_preseed { "preseed":
	template => "preseed.erb"
}
ubuntu_preseed { "preseed-ceph":
	template => "preseed-ceph.erb",
	diskpart => ["/dev/sda", "/dev/sdb"]
}
ubuntu_preseed { "preseed-compute":
	template => "preseed-compute.erb"
}

####### Install and configure Cobbler service
class { cobbler: 
  node_subnet      => $::node_subnet, 
  node_netmask     => $::node_netmask,
  node_gateway     => $::node_gateway,
  node_dns         => $::node_dns,
  ip               => $::cobbler_node_ip,
  dns_service      => $::dns_service,
  dhcp_service     => $::dhcp_service,
  dhcp_ip_low      => $::dhcp_ip_low,
  dhcp_ip_high     => $::dhcp_ip_high,
  domain_name      => $::domain_name,
  password_crypted => $::password_crypted,
}

# This will load the Ubuntu Server OS into cobbler
# COE supprts only Ubuntu precise x86_64
 cobbler::ubuntu { "precise":
  proxy => $::proxy,
 }
   class { 'zabbix::agent':
  		zabbix_server => '127.0.0.1'
  }
  
  exec { "enable-ccc-site":
	command => "a2ensite ccc",
	provider => shell,
	notify  => Service['httpd'],
	unless => "/bin/readlink -e /etc/apache2/sites-enabled/ccc",
  }
}