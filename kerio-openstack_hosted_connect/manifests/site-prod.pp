# maly (c) 2013
########### Build Node (Cobbler, Puppet Master, NTP) ######
# Change the following to the host name you have given your build node.
# This name should be in all lower case letters due to a Puppet limitation
# (refer to http://projects.puppetlabs.com/issues/1168).
$build_node_name = "build-server"

########### NTP Configuration ############
# Change this to the location of a time server in your organization accessible to the build server
# The build server will synchronize with this time server, and will in turn function as the time
# server for your OpenStack nodes
$ntp_servers	= ["ntp.server.com"]

########### Build Node Cobbler Variables ############
# Change these 5 parameters to define the IP address and other network settings of your build node
# The cobbler node *must* have this IP configured and it *must* be on the same network as
# the hosts to install
$cobbler_node_ip 	= '172.31.31.4'
$node_subnet 			= '172.31.31.0'
$node_netmask 		= '255.255.255.0'
$node_gateway 		= '172.31.31.1'
$node_dns       	= '172.31.31.1'
$dns_service 			= "dnsmasq"
$dhcp_service 		= "dnsmasq"
$time_zone      	= "UTC"
$dhcp_ip_low     	= "172.31.31.200"
$dhcp_ip_high    	= "172.31.31.250"

# This domain name will be the name your build and compute nodes use for the local DNS
# It doesn't have to be the name of your corporate DNS - a local DNS server on the build
# node will serve addresses in this domain - but if it is, you can also add entries for
# the nodes in your corporate DNS environment they will be usable *if* the above addresses
# are routeable from elsewhere in your network.
$domain_name 		= 'domain.net'

# This setting likely does not need to be changed
# To speed installation of your OpenStack nodes, it configures your build node to function
# as a caching proxy storing the Ubuntu install files used to deploy the OpenStack nodes
$cobbler_proxy 		= "http://${cobbler_node_ip}:3142/"

# Here should be defined Zabbix server gathering data from Zabbix proxy
# Zabbix server should have defined remote proxy (DM) with name $zabbix_proxy_name and allowed incomming traffic to port 10051
$zabbix_server 			= "xxx.xxx.xxx.xx"
$zabbix_proxy_name	= "hc-zabbix-proxy"
$zabbix_proxy_ip		= "xxx.xx.xx.x"

############ CEPH configuration values ############
# some values in this section can be provided only after deploying CEPH nodes and configuring CEPH cluster.
#
# CEPH pool for storing nova volumes
	$rbd_pool		='volumes'
#
# CEPH user for logging into CEPH cluster. Must be created by command:
# ceph auth get-or-create client.volumes mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=volumes' -o /etc/ceph/client.volumes.keyring
	$rbd_user		= 'volumes'
#
# this UUID should be any unique UUID - will be used to store cephx_key into libvirt on all Compute nodes (virsh secret-set-value)
# the key is created only once and it's not updated even if you change rbd_cephx_key here. If you update rbd_cephx_key, you need to remove
# virsh secret from all nodes to apply changes (virsh secret-undefine <<KEY REMOVED FOR PRIVACY REASONS>>) and they reapply puppet scripts.
	$rbd_secret_uuid = '<<KEY REMOVED FOR PRIVACY REASONS>>'
#
# this needs to be changed - here is cephx auth key generated for user "volumes" by command above (in file /etc/ceph/client.volumes.keyring)
# 
	$rbd_cephx_key 	= '<<KEY REMOVED FOR PRIVACY REASONS>>'
# 
# !!!! the files /etc/ceph/client.volumes.keyring and ceph.conf must be copied to /etc/ceph on all cinder-volume nodes !!!!!
# ceph.conf must be extended by:
#	[client.volumes]
# keyring = /etc/ceph/client.volumes.keyring
###################################################

####### Preseed File Configuration #######
# This will build a preseed file called 'preseed' in /etc/cobbler/preseeds/
# The preseed file automates the installation of Ubuntu onto the OpenStack nodes
#
# The following variables may be changed by the system admin:
# 1) admin_user
# 2) password_crypted
# 3) autostart_puppet -- whether the puppet agent will auto start
# Default user is: admin
# Default SHA-512 hashed password is "password": <<KEY REMOVED FOR PRIVACY REASONS>>
# To generate a new SHA-512 hashed password, run the following replacing
# the word "password" with your new password. Then use the result as the
# $password_crypted variable
# python -c "import crypt, getpass, pwd; print crypt.crypt('password', '\$6\$<<KEY REMOVED FOR PRIVACY REASONS>>\$')"
$admin_user 				= 'admin'
$password_crypted 	= '<<KEY REMOVED FOR PRIVACY REASONS>>'
$autostart_puppet   = true

# Select the drive on which Ubuntu and OpenStack will be installed in each node. Current assumption is
# that all nodes will be installed on the same device name
$install_drive           = '/dev/sda'

#----------------------------------------------------
####### Openstack shared variables ##################
#----------------------------------------------------

# this section is used to specify global variables that will
# be used in the deployment of multi and single node openstack
# environments

# assumes that eth0 is the public interface
	$public_interface        = 'bond0'
	$private_interface		   = 'bond1'
# assumes that eth1 is the interface that will be used for the vm network
# this configuration assumes this interface is active but does not have an
# ip address allocated to it.
	$flat_interface          = 'dummy0'
# credentials
	$admin_email             = 'root@localhost'
	$admin_password          = '<<KEY REMOVED FOR PRIVACY REASONS>>'
	$keystone_db_password    = 'keystone_db_pass'
	$keystone_admin_token    = '<<KEY REMOVED FOR PRIVACY REASONS>>'
	$nova_db_password        = 'nova_pass'
	$nova_user_password      = 'nova_pass'
	$glance_db_password      = 'glance_pass'
	$glance_user_password    = 'glance_pass'
	$rabbit_password         = 'openstack_rabbit_password'
	$rabbit_user             = 'openstack_rabbit_user'
	$fixed_network_range     = '192.168.101.0/24'
	$floating_network_range  = 'xxx.xx.xx.x/24'
	$cinder_db_password		   = 'cinder_pass'
	$cinder_user_password    = 'cinder_pass'
	
# switch this to true to have all service log at verbose
	$verbose                 = false
# by default it does not enable atomatically adding floating IPs
	$auto_assign_floating_ip = false

	$controller_node_address  = '172.31.31.10'
	$controller_node_netmask  = '255.255.255.0'
	$controller_node_gateway  = 'xxx.xx.xx.x'
	$controller_node_public   = 'xxx.xx.xx.x'
	$controller_node_internal = $controller_node_address

	#iptables settings - allow all traffic from there IP ranges
	$allowed_ranges = ["xxx.xx.xx.x/24"]

####### OpenStack Node Definitions #####
# This section is used to define the hardware parameters of the nodes which will be used
# for OpenStack. Cobbler will automate the installation of Ubuntu onto these nodes using
# these settings
node /build-node/ inherits master-node {

# This block defines the control server. Replace "control_server" with the 
# host name of your OpenStack controller, and change the "mac" to the MAC 
# address of the boot interface of your OpenStack controller. Change the 
# "ip" to the IP address of your OpenStack controller.
  cobbler_node { "controller01":
  	ip 			=> "172.31.31.10",
  	gateway => $::controller_node_gateway,
  	preseed => "/etc/cobbler/preseeds/preseed"
	}
  cobbler::node::interface { "controller01-eth0":
	server 					=> "controller01",
	interface_name 	=> "eth0",
	mac 						=> "00:00:00:00:00:00",
	ip 							=> "172.31.31.10",
	subnet 					=> "255.255.255.0",
	static 					=> 1,
	management 			=> 0,
	require 				=> Cobbler_node["controller01"]
    }
  cobbler::node::interface { "controller01-eth1":
  server 					=> "controller01",
	interface_name 	=> "eth1",
	mac 						=> "00:00:00:00:00:00",
	ip 							=> "xxx.xx.xx.x",
	subnet 					=> "255.255.255.0",
	static 					=> 1,
	management 			=> 1,
	require 				=> Cobbler_node["controller01"]
    }

# This block defines the first compute server. Replace "compute_server01" 
# with the host name of your first OpenStack compute node (note: the hostname
# should be in all lowercase letters due to a limitation of Puppet; refer to
# http://projects.puppetlabs.com/issues/1168), and change the "mac" to the 
# MAC address of the boot interface of your first OpenStack compute node. 
# Change the "ip" to the IP address of your first OpenStack compute node.

# Begin compute node
#  cobbler_node { "ncn01":
#    mac 						=> "00:00:00:00:00:00",
#    ip 						=> "192.168.52.78",
#    power_address  => "192.168.242.121"
#  }
#===============================================================================
  cobbler_node { "ncn01":
  	ip 			=> "172.31.31.21",
  	gateway => $::controller_node_gateway
	}
  cobbler::node::interface { "ncn01-eth0":
  server 						=> "ncn01",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-eth1":
  server 						=> "ncn01",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-eth2":
  server 						=> "ncn01",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-eth3":
  server 						=> "ncn01",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-bond0":
	server 						=> "ncn01",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "xxx.xx.xx.x",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-bond1":
	server 						=> "ncn01",
	interface_name 		=> "bond1",
	interface_type 		=> "bond",
	ip 								=> "172.31.31.21",
	subnet 						=> $::controller_node_netmask,
	static 						=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn01"]
    }
  cobbler::node::interface { "ncn01-dummy0":
	server 						=> "ncn01",
	interface_name 		=> "dummy0",
	interface_type 		=> "",
	ip 								=> "",
	subnet 						=> $::controller_node_netmask,
	require 					=> Cobbler_node["ncn01"]
    }
#===============================================================================    
  cobbler_node { "ncn02":
  	ip 			=> "172.31.31.22",
  	gateway => $::controller_node_gateway
	}

  cobbler::node::interface { "ncn02-eth0":
  server 						=> "ncn02",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn02"]
    }
  cobbler::node::interface { "ncn02-eth1":
  server 						=> "ncn02",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn02"]
    }    
  cobbler::node::interface { "ncn02-bond0":
	server 						=> "ncn02",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "xxx.xx.xx.x",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn02"]
    }
  cobbler::node::interface { "ncn02-eth2":
  server 						=> "ncn02",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn02"]
    }
  cobbler::node::interface { "ncn02-eth3":
  server 						=> "ncn02",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn02"]
    }
  cobbler::node::interface { "ncn02-bond1":
	server 						=> "ncn02",
	interface_name 		=> "bond1",
	interface_type		=> "bond",
	ip 								=> "172.31.31.22",
	subnet 						=> $::controller_node_netmask,
	static 						=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn02"]
    }
  cobbler::node::interface { "ncn02-dummy0":
	server 						=> "ncn02",
	interface_name 		=> "dummy0",
	interface_type 		=> "",
	ip 								=> "",
	subnet 						=> $::controller_node_netmask,
	require 					=> Cobbler_node["ncn02"]
    }
      
#===============================================================================    
  cobbler_node { "ncn03":
  	ip 			=> "172.31.31.23",
  	gateway => $::controller_node_gateway
	}

  cobbler::node::interface { "ncn03-eth0":
  server 						=> "ncn03",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn03"]
    }
  cobbler::node::interface { "ncn03-eth1":
    server 					=> "ncn03",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ncn03"]
    }    
  cobbler::node::interface { "ncn03-bond0":
	server 						=> "ncn03",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "xxx.xx.xx.x",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn03"]
    }
  cobbler::node::interface { "ncn03-eth2":
  server 						=> "ncn03",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn03"]
    }
  cobbler::node::interface { "ncn03-eth3":
  server 						=> "ncn03",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ncn03"]
    }
  cobbler::node::interface { "ncn03-bond1":
	server 						=> "ncn03",
	interface_name 		=> "bond1",
	interface_type 		=> "bond",
	ip 								=> "172.31.31.23",
	subnet 						=> $::controller_node_netmask,
	static 						=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ncn03"]
    }
  cobbler::node::interface { "ncn03-dummy0":
	server 						=> "ncn03",
	interface_name 		=> "dummy0",
	interface_type 		=> "",
	ip 								=> "",
	subnet 						=> $::controller_node_netmask,
	require 					=> Cobbler_node["ncn03"]
    }        

#####################
# Begin CEPH nodes
#####################

  cobbler_node { "ceph1":
	ip 					=> "172.31.31.51",
    preseed   => "/etc/cobbler/preseeds/preseed-ceph"
}
  cobbler::node::interface { "ceph1-eth0":
	server 						=> "ceph1",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph1"]
    }
  cobbler::node::interface { "ceph1-eth1":
	server 						=> "ceph1",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph1"]
    }
  cobbler::node::interface { "ceph1-bond0":
	server 						=> "ceph1",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "172.32.32.51",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 0,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph1"]
    }
  cobbler::node::interface { "ceph1-eth2":
	server 						=> "ceph1",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph1"]
    }
  cobbler::node::interface { "ceph1-eth3":
	server 						=> "ceph1",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph1"]
    }
  cobbler::node::interface { "ceph1-bond1":
	server 						=> "ceph1",
	interface_name 		=> "bond1",
	interface_type 		=> "bond",
	ip 								=> "172.31.31.51",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 0,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph1"]
    }
#===============================================================================
  cobbler_node { "ceph2":
	ip 					=> "172.31.31.52",
    preseed   => "/etc/cobbler/preseeds/preseed-ceph"
}
  cobbler::node::interface { "ceph2-eth0":
	server 						=> "ceph2",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph2"]
    }
  cobbler::node::interface { "ceph2-eth1":
	server 						=> "ceph2",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph2"]
    }
  cobbler::node::interface { "ceph2-bond0":
	server 						=> "ceph2",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "172.32.32.52",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 0,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph2"]
    }
  cobbler::node::interface { "ceph2-eth2":
	server 						=> "ceph2",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph2"]
    }
  cobbler::node::interface { "ceph2-eth3":
	server 						=> "ceph2",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph2"]
    }
  cobbler::node::interface { "ceph2-bond1":
	server 						=> "ceph2",
	interface_name 		=> "bond1",
	interface_type 		=> "bond",
	ip 								=> "172.31.31.52",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph2"]
    }
#===============================================================================      
cobbler_node { "ceph3":
	ip 					=> "172.31.31.53",
    preseed   => "/etc/cobbler/preseeds/preseed-ceph"
}
  cobbler::node::interface { "ceph3-eth0":
	server 						=> "ceph3",
	interface_name 		=> "eth0",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph3"]
    }
  cobbler::node::interface { "ceph3-eth1":
	server 						=> "ceph3",
	interface_name 		=> "eth1",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond0",
	require 					=> Cobbler_node["ceph3"]
    }
  cobbler::node::interface { "ceph3-bond0":
	server 						=> "ceph3",
	interface_name 		=> "bond0",
	interface_type 		=> "bond",
	ip 								=> "172.32.32.53",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 0,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph3"]
    }
  cobbler::node::interface { "ceph3-eth2":
	server 						=> "ceph3",
	interface_name 		=> "eth2",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph3"]
    }
  cobbler::node::interface { "ceph3-eth3":
	server 						=> "ceph3",
	interface_name 		=> "eth3",
	mac 							=> "00:00:00:00:00:00",
	interface_type 		=> "bond_slave",
	interface_master 	=> "bond1",
	require 					=> Cobbler_node["ceph3"]
    }
  cobbler::node::interface { "ceph3-bond1":
	server 						=> "ceph3",
	interface_name 		=> "bond1",
	interface_type 		=> "bond",
	ip 								=> "172.31.31.53",
	subnet 						=> "255.255.255.0",
	static 						=> 1,
	management 				=> 1,
	bonding_opts 			=> "mode=active-backup miimon=100",
	require 					=> Cobbler_node["ceph3"]
    }
#####################
# END CEPH nodes
#####################
#===============================================================================      
cobbler_node { "backup01":
	ip => "172.31.31.41",
    preseed => "/etc/cobbler/preseeds/preseed-ceph",
    gateway => $::controller_node_gateway
}
  cobbler::node::interface { "backup01-eth0":
	server 							=> "backup01",
	interface_name 			=> "eth0",
	mac									=> "00:00:00:00:00:00",
	interface_type 			=> "bond_slave",
	interface_master 		=> "bond0",
	require 						=> Cobbler_node["backup01"]
    }
  cobbler::node::interface { "backup01-eth1":
	server 							=> "backup01",
	interface_name 			=> "eth1",
	mac 								=> "00:00:00:00:00:00",
	interface_type 			=> "bond_slave",
	interface_master 		=> "bond0",
	require 						=> Cobbler_node["backup01"]
    }
  cobbler::node::interface { "backup01-bond0":
	server 							=> "backup01",
	interface_name 			=> "bond0",
	interface_type 			=> "bond",
	ip 									=> "172.31.31.41",
	subnet 							=> "255.255.255.0",
	static 							=> 1,
	management 					=> 0,
	bonding_opts 				=> "mode=active-backup miimon=100",
	require 						=> Cobbler_node["backup01"]
    }
  cobbler::node::interface { "backup01-eth2":
	server 							=> "backup01",
	interface_name 			=> "eth2",
	mac 								=> "00:00:00:00:00:00",
	interface_type 			=> "bond_slave",
	interface_master 		=> "bond1",
	require 						=> Cobbler_node["backup01"]
    }
  cobbler::node::interface { "backup01-eth3":
	server 							=> "backup01",
	interface_name 			=> "eth3",
	mac 								=> "00:00:00:00:00:00",
	interface_type 			=> "bond_slave",
	interface_master 		=> "bond1",
	require						  => Cobbler_node["backup01"]
    }
  cobbler::node::interface { "backup01-bond1":
	server 							=> "backup01",
	interface_name 			=> "bond1",
	interface_type 			=> "bond",
	ip 									=> "xxx.xx.xx.x",
	subnet 							=> "255.255.255.0",
	static 							=> 1,
	management 					=> 1,
	bonding_opts 				=> "mode=active-backup miimon=100",
	require 						=> Cobbler_node["backup01"]
    }
}

### Node types ###
# Change build_server to the host name of your build node

node 'build-server' inherits build-node { }

node 'controller01' inherits os_base { 
  class { 'control-node': }
}
node 'ncn01' inherits os_base {
  class { 'compute-node':
    internal_ip => '172.31.31.21',
  }
}
node 'ncn02' inherits os_base {
  class { 'compute-node':
    internal_ip => '172.31.31.22',
  }
}
node 'ncn03' inherits os_base {
  class { 'compute-node':
    internal_ip => '172.31.31.23',
  }
}

#
# CEPH nodes
#
node /ceph\d+/ inherits os_base { 
	class { 'ceph-node': }
}

node /backup\d+/ inherits os_base { 
}

#
# Connect virtual instances
#
node /cloud-\d+/ inherits os_instance { 
}
# migrated instances have names like XXXXX-c-123
node /^[a-z0-9]+-c-\d+$/ inherits os_instance { }

########################################################################
### All parameters below this point likely do not need to be changed ###
########################################################################

### Advanced Users Configuration ###
# Enable network interface bonding. This will only enable the bonding module in the OS, 
# it won't acutally bond any interfaces. Edit the networking interfaces template to set 
# up interface bonds as required after setting this to true should bonding be required.
$interface_bonding = 'true' 

# Enable ipv6 router edvertisement
#$ipv6_ra = '1'

# Configure the maximum number of times mysql-server will allow
# a host to fail connecting before banning it
$max_connect_errors = '10'

### Puppet Parameters ###
# These settings load other puppet components. They should not be changed
import 'cobbler-node'
import 'core'
import 'control-node'
import 'compute-node'
import 'ceph-node'

## Define the default node, to capture any un-defined nodes that register
## Simplifies debug when necessary.

node default {
  notify{"Default Node: Perhaps add a node definition to site.pp": }
}
# Note: all of the xxx.xxx.xx.x in the above text are public IP addresses
#       all of the 00:00:00:00:00:00 are MAC addresses of the NICs