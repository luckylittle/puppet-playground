# maly (c) 2013
class compute-node ( $internal_ip ) {

	Class ['openstack::repo'] -> Class['openstack::compute']

	class { 'openstack::repo': }
	class { 'openstack::compute': 
  		private_interface  => $::flat_interface,
  		internal_address   => $internal_ip,
  		public_interface   => $::public_interface,
  		fixed_range        => $::fixed_network_range,
  		network_manager    => 'nova.network.manager.FlatDHCPManager',
  		network_config	   => {flat_injected => true},
  		multi_host         => true,
  		rabbit_host        => $::controller_node_address,
  		db_host 		   => $::controller_node_address,
  		nova_db_password        => $::nova_db_password,
	    nova_user_password      => $::nova_user_password,
	    rabbit_password         => $::rabbit_password,
   		rabbit_user             => $::rabbit_user,
  		glance_api_servers => "${::controller_node_address}:9292",
  		vncproxy_host      => $::controller_node_public,
  		vnc_enabled        => true,
  		manage_volumes     => false,
  		cinder_db_password => $::cinder_db_password,
  		quantum			   => false }
		

	class{'ceph::repo': }
	
	package{"ceph-common" : 
	   ensure => installed,
	   require => Class["ceph::repo"]
	}	

	class{'node-firewall': 
		restart_services  => [Service['nova-compute'], Service['nova-api'], Service['nova-network']]
	}
	
	#setup Cinder-volume to use RBD (CEPH)
#	class {'cinder::volume::rbd':
#  		rbd_pool 			=> $::rbd_pool,
#		rbd_user 			=> $::rbd_user,
#		rbd_secret_uuid    	=> $::rbd_secret_uuid,
#		require 			=> Class['openstack::compute'],
#		notify 				=> Exec["virsh-add-secret"]
#	} 	
	
	#add cephx auth key as a secret into virsh on every compute node.
	exec {"virsh-add-secret":
		command 	=> "echo \"<secret ephemeral='no' private='no'>
   <uuid>${rbd_secret_uuid}</uuid>
   <usage type='ceph'>
     <name>client.admin secret</name>
   </usage>
</secret>\" > /tmp/secret.xml;\
virsh secret-define /tmp/secret.xml ;\
virsh secret-set-value --secret ${rbd_secret_uuid} --base64 ${rbd_cephx_key}",
			path     => [ "/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin", "/usr/local/sbin" ],
			unless => "virsh secret-list | grep -c ${rbd_secret_uuid}",
			notify  => Service['nova-compute']
  		}

  				
	#add some stuff to nova.conf
	nova_config {
		'DEFAULT/volume_driver': value => 'nova.volume.driver.RBDDriver';
		'DEFAULT/rbd_pool': value => $::rbd_pool;
		'DEFAULT/rbd_user': value => $::rbd_user;
		'DEFAULT/rbd_secret_uuid': value => $::rbd_secret_uuid;
    }
}