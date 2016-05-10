#!/usr/bin/ruby
# Oracle Corporation
# 2015-05-08

#Usage:
# Parameter is the file you are searching in. The output will give you the fourth word on the third line


#Initialization, put everything to null
line_number=0
contentArray=[] 


#Reading the test.txt file
text=File.open('test.txt').read
text.each_line do |line|
  "#{line_number += 1}"

  
#When you reach line 3, put each word on the line into an array
  if line_number==3 then
  #Split by any non-word character into an array
	contentArray = line.strip.split(/\W+/)
    #Show the 4th entry in the array
	print "The fourth word on the third line is: "
	print contentArray[4]
	print "\n"
		 end
end
