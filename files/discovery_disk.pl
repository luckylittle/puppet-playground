#!/usr/bin/perl
# maly (c) 2013
# Zabbix 2 - disk autodiscovery for linux
# all disks listed in /proc/diskstats are returned
# special processing on LVMs
# special processing on Proxmox VE disks (VM id and VM name are returned)
# rq : in Zabbix, create a regexp filter on which disks you want to monitor on your IT System
# ex : ^(hd[a-z]+|sd[a-z]+|vd[a-z]+|dm-[0-9]+|drbd[0-9]+)$	
#      ^(loop[0-9]+|sr[0-9]*|fd[0-9]*)$

$firstline = 1;
print "{ \"data\":[";

for (`cat /proc/diskstats`)
  {
  ($major,$minor,$disk) = m/^\s*([0-9]+)\s+([0-9]+)\s+(\S+)\s.*$/;
  $diskdev = "/dev/$disk";
  #print("$major $minor $disk $diskdev $dmname $vmid $vmname \n");

  print "," if not $firstline;
  $firstline = 0;

  print "\n{";
  print "\"{#DISK}\":\"$disk\",";
  print "\"{#DISKDEV}\":\"$diskdev\"";
  print "}";
  }

print "]";
print "}\n";
