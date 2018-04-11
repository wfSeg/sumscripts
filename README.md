Readme

HOW TO RUN
1. Use AUTOPXE or ONOFF Tracker
2. cburn DIR=/sysv/YourDirectory RC=http://172.16.113.224/scripts/ipmitest.sh
3. When tests are done, check your cburn/sysv directory for logs

Notes on editing scripts
1. Using Sublime text in Windows, for scripts, make sure file is UNIX to run in Linux.
View -> Line Endings -> Unix
2. Directories
	For server script testing
	/var/www/html/wakanda.com/public_html/scripts/smc-temp.sh 
	For local system testing
	/usr/local/sbin/smc-temp.sh
3. when calling a script inside smc-temp.sh, it's better to use "sh script.sh" instead of "./script.sh" - i guess?
4. when using mapfile, and calling it with:
		for i in "${frucmd[@]}";
	use quotes! " " around the array, otherwise it will call each word as an individual value, instead of each line.

TO DO
1. Add "sum" tool testing
2. Add in the rest of SMCIPMITool commands
3. Find a way to parse output of logs $RDIR/$IPMI-$(date +%Y-%m-%d).log"
