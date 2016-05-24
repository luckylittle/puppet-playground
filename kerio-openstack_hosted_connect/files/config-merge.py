#!/usr/bin/python
# maly (c) 2013
# This script will copy some values from orgiinal mailserver.cfg file to the file imported by a customer.
# Our cloud requires some items to be set to specific values (paths) which may be different in customer's backup
# file and therefore needs to be replaced with correct values.
# Also our Connects in the Cloud contain SpecialAccount to access Cloud instance.
#
from optparse import OptionParser
import xml.etree.ElementTree as xml

parser = OptionParser()
parser.add_option("-i", "--input", dest="infilename",
                  help="source config from file", metavar="FILE")
parser.add_option("-o", "--output", dest="outfilename",
                  help="destination config file", metavar="FILE")

(options, args) = parser.parse_args()

if not options.infilename:
	parser.error("incorrect number of arguments")

if not options.outfilename:
	parser.error("incorrect number of arguments")

infilename = options.infilename
outfilename = options.outfilename

print 'Some config values will be merged from ', infilename, ' to ' , outfilename

#load the original Cloud file
tree = xml.parse(infilename)
root = tree.getroot()

#load imported config file from the customer
tree_new = xml.parse(outfilename)
root_new = tree_new.getroot()

#find section "SpecialAccount" and append users to the new config
parent_new = tree_new.find(".//*[@name='SpecialAccount']")
parent = tree.find(".//*[@name='SpecialAccount']")
for child in parent:
	parent_new.append(child);

	#function to replace one value in both files
def replaceOneValue(item):
	parent = tree.find(item)
    	parent_new = tree_new.find(item)
    	print "replacing this: ",parent_new.tag, parent_new.attrib, parent_new.text
    	print "with this     : ", parent.tag, parent.attrib, parent.text
    	parent_new.text = parent.text

#replace those values with Cloud ones
replaceOneValue(".//table[@name='FullTextSearch']/variable[@name='Path']")
replaceOneValue(".//table[@name='Directories']/variable[@name='StoreDir']")
replaceOneValue(".//table[@name='Directories']/variable[@name='ArchiveDir']")
replaceOneValue(".//table[@name='Directories']/variable[@name='BackupDir']")
replaceOneValue(".//table[@name='InstantMessaging']/variable[@name='StorePath']")
replaceOneValue(".//table[@name='LogGlobal']/variable[@name='RelativePathsRoot']")

#disable product backup
parent_new = tree_new.find(".//table[@name='Backup']/variable[@name='Enabled']")
parent_new.text = "0"

tree_new.write(outfilename)
