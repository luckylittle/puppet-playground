#!/usr/bin/ruby
# Oracle Corporation
# 2015-10-08

# Usage:
# It loops through the modules in the r10k Puppetfile (development branch) and refreshes each modules development branch, or clones each repo if not present.
# This script must be run from the controlrepo root folder. It looks for the Puppetfile in the project root folder.

# Requires:
require 'fileutils'


# If the module exists do a git pull to get the latest pull:
def refresh_module(path, name, branch)
  startingdir = Dir.pwd
  if !Dir.chdir("#{path}/#{name}")
    puts "Error: Path #{path}/#{name} does not exist"
    exit
  else
    if `git rev-parse --abbrev-ref HEAD`.chomp != branch
      `git checkout #{branch} -q`
    end
    `git pull`
    Dir.chdir(startingdir)
  end
end


# Cloning part starts here:
def clone_module(location, gitpath, name, branch)
  startingdir = Dir.pwd
  if !Dir.chdir(location)
    puts "Error: Path #{location} for cloning module #{name} doesn't exist"
    exit
  else
    `git clone #{gitpath} #{name}`
    Dir.chdir(name)
    if `git rev-parse --abbrev-ref HEAD` != branch
      `git checkout #{branch} -q`
    end
    Dir.chdir(startingdir)
  end
end


# The Puppetfile contains each puppet module and git location and must exist:
if !File.exist?('Puppetfile')
  puts 'ERROR: Puppetfile not found in current directory'
  exit
end


# Get the current branch that we are on in the control repo, so we can setup the environment:
environment = `git rev-parse --abbrev-ref HEAD`.chomp
if (environment != 'development') && (environment !='production')
  puts "Environment #{environment} is not development or production. Exiting"
  exit
end
STDOUT.flush


# Create the folder structure for the modules:
if !Dir.exist?("environments/#{environment}/modules")
  FileUtils.mkdir_p "environments/#{environment}/modules"
end


# Open the puppet file and iterate through the lines, grep for the ssh git line:
module_name = ''
branch_name = ''
git_path = ''
modules_path = "environments/#{environment}/modules/"
File.open('Puppetfile', 'r') do |file_handle|
  file_handle.each_line do |read_line|
    # Process lines that start with mod definition:
    if read_line.start_with? 'mod'
      module_name = read_line.split('\'')[1]
    end # if line starts with mod
    # Process lines that start with :git definition:
    if read_line.include? ':git'
      git_path = read_line.split('\'')[1]
    end # if line starts with :git line
    # Process lines that start with :tag or ref definition:
    if (read_line.include? ':ref') || (read_line.include? ':tag')
      branch_name = read_line.split('\'')[1]
      # see if module exists
      if Dir.exist?("#{modules_path}#{module_name}")
        puts "--- #{module_name} Exists... checking out #{branch_name} branch and running git pull"
        STDOUT.flush
        refresh_module(modules_path, module_name, branch_name)
      else
        puts "--- #{module_name} Missing... Cloning module and checking out #{branch_name} branch"
        STDOUT.flush
        clone_module(modules_path, git_path, module_name, branch_name)
      end
      # Reset the variables so we can process the next line
      module_name = ''
      branch_name = ''
      git_path = ''
    end
  end
end