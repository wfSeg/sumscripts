HOW TO RUN

1. Use AUTOPXE or ONOFF Tracker
2. cburn DIR=/sysv/YourDirectory RC=http://172.16.113.224/scripts/ipmitest.sh
3. When tests are done, check your cburn/sysv directory for logs

Using Sublime text in Windows, for scripts, need to make sure it is UNIX to run in Linux.
View -> Line Endings -> Unix

Directories
	For server script testing
	/var/www/html/wakanda.com/public_html/scripts/smc-temp.sh 
	For local system testing
	/usr/local/sbin/smc-temp.sh

misc
- when calling a script inside smc-temp.sh, it's better to use "sh script.sh" instead of "./script.sh" - i guess?
- when using mapfile, and calling it with
	for i in "${frucmd[@]}";
	- use quotes! " " around the array, otherwise it will call each word as an individual value, instead of each line.