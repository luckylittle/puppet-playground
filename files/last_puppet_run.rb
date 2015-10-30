#!/usr/bin/env ruby
# maly (c) 2013
require "yaml"
 
@statefile = "/var/lib/puppet/state/last_run_summary.yaml"
summary = YAML.load_file(@statefile)
 
resources = {"failed"=>0, "changed"=>0, "total"=>0, "restarted"=>0, "out_of_sync"=>0}.merge(summary["resources"])
puppettime = {"total"=>0 }.merge(summary["time"]) 
lastrunseconds = 0
lastrunseconds = File.stat(@statefile).mtime.to_i if File.exists?(@statefile)
lastrunsecondsago = Time.now.to_i - lastrunseconds
 
puts <<END_OF_REPORT
puppet.lastrun-failed #{resources["failed"]}
puppet.lastrun-changed #{resources["changed"]}
puppet.lastrun-total #{resources["total"]}
puppet.lastrun-restarted #{resources["restarted"]}
puppet.lastrun-outofsync #{resources["out_of_sync"]}
puppet.lastrun-secondsago #{lastrunsecondsago}
puppet.lastrun-time #{puppettime["total"]}
END_OF_REPORT
