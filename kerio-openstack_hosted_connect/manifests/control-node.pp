# maly (c) 2013
class control-node {
  class { 'openstack::controller':
    public_address          => $controller_node_public,
    admin_address           => $controller_node_public,
    public_interface        => $public_interface,
    private_interface       => $flat_interface,
    internal_address        => $controller_node_internal,
    floating_range          => $floating_network_range,
    fixed_range             => $fixed_network_range,
    multi_host              => true,
    # by default is assumes flat dhcp networking mode
    network_manager         => 'nova.network.manager.FlatDHCPManager',
    verbose                 => $verbose,
    auto_assign_floating_ip => $auto_assign_floating_ip,
    mysql_root_password     => $mysql_root_password,
    admin_email             => $admin_email,
    admin_password          => $admin_password,
    keystone_db_password    => $keystone_db_password,
    keystone_admin_token    => $keystone_admin_token,
    glance_db_password      => $glance_db_password,
    glance_user_password    => $glance_user_password,
    nova_db_password        => $nova_db_password,
    nova_user_password      => $nova_user_password,
    rabbit_password         => $rabbit_password,
    rabbit_user             => $rabbit_user,
	#Horizon secret key
    secret_key              => "12345",
    quantum                 => false,
    cinder		    		=> true,
    cinder_db_password		=> $cinder_db_password,
    cinder_user_password	=> $cinder_user_password, 
    require 		    => Class['openstack::repo'],
  }
  
  #add Ubuntu-cloud Openstack repository
  class { 'openstack::repo': }

  #create a file with auth credentials at /root/openrc
  class { 'openstack::auth_file':
    admin_password       => $admin_password,
    keystone_admin_token => $keystone_admin_token,
    controller_node      => $controller_node_internal,
  }
  
  #add CEPH oficial repository
	class{'ceph::repo': }

	#add CEPH packages for use with Cinder and Glance	
	package{"ceph-common" : 
	   ensure => installed,
	   require => Class["ceph::repo"]
	}
	
	#increase default project quota in nova.conf
	class { 'nova::quota' :
  		quota_instances => 100,
  		quota_cores => 200,
  		quota_ram => 128000,
  		quota_floating_ips => 100,
  		quota_security_groups => 10,
  		quota_security_group_rules => 25
  	}
    cinder_config {
      'DEFAULT/quota_volumes':   	value => '100';
      'DEFAULT/quota_snapshots':	value => '100';
      'DEFAULT/quota_gigabytes':  value => '10000';
      'DEFAULT/max_gigabytes':  value => '100000';
    }
}