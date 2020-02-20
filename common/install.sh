ui_print "*****************************************"
ui_print "Magisk Google Pay SQL Fix" 
ui_print "(Full Edition)"
ui_print " "
ui_print "The fix features the work of:"
ui_print " "
ui_print "BostonDan - for the OP and original fix"
ui_print " "	
ui_print "braveheartleo - for the chattr suggestion"
ui_print " "
ui_print "Didgeridoohan - for the working method to hide" 
ui_print "Google Play Services via magiskhide in a script loop"
ui_print " "
ui_print "Zackptg5 - for the MMM-EXT module format and help switching to it"
ui_print " "
ui_print "Skittles9823 - for help during switch to MMM-EXT module format"
ui_print " "
ui_print "jcmm11 - for help during switch to MMM-EXT module format"

ui_print "*****************************************"
ui_print " "
sleep 2

# check for required files
ui_print "Checking for required files...."
ui_print " "
# check where sqlite3 is
ui_print "Checking for sqlite3 binary...."
	if [ -f /data/data/com.termux/files/usr/bin/sqlite3 ] ; then
		sqlpath=/data/data/com.termux/files/usr/bin
		ui_print "[termux] SQLite3 binary found in: $sqlpath"
	elif [ -f /data/data/com.keramidas.TitaniumBackup/files/sqlite3 ] ; 	then
		sqlpath=data/data/com.keramidas.TitaniumBackup/files/sqlite3
		ui_print "[titanium] SQLite3 binary found in: $sqlpath"	
	elif [ -f /system/bin/sqlite3 ] ; 	then
		sqlpath=/system/bin
		ui_print "[standard] SQLite3 binary found in: $sqlpath"
	elif [ -f /system/xbin/sqlite3 ] ; then
		sqlpath=/system/xbin
		ui_print "[standard] SQLite3 binary found in: $sqlpath"
	else 
		ui_print "SQLite3 binary not found, please install an SQLite3 binary, without this the fix may not work"
		ui_print "Please read the original post (see support link) or /cache/playfixfirstrun.log after reboot for further info"
	fi 	
ui_print " "
sleep 2
	
# hide packages known to affect GPay using magiskhide
ui_print "Attempting to hide packages known to affect GPay using magiskhide..."
# the following few lines are contributed by digderidoohan - thanks for the delimiter and cutting routine for hiding Google Services Framework
# i tried many ways of delimiting etc and none worked, his did, champion!
packages='com.google.android.gsf_com.google.process.gapps com.google.android.gsf_com.google.process.gservices com.google.android.gms com.google.android.apps.walletnfcrel'
	for i in $packages
		do magiskhide add $(echo $i | cut -f 1 -d '_') $(echo $i | cut -f 2 -d '_')
		if [ $? -eq 0 ] ;	then
			ui_print "$i: hidden successfully"
		else
			ui_print "$i: already hidden"	
		fi
	done
ui_print " "
sleep 2	

# clear Google Pay cache & storage, or not...now user gets a choice thanks to keycheck
ui_print "Clear cache and storage for Google Pay?"
ui_print " "
ui_print "WARNING: This *may* clear data used for Loyalty Cards & Passes"
ui_print " "
ui_print "  Vol+ = Yes, clear, i understand the RISKS"
ui_print " "
ui_print "  Vol- = No, DONT clear, i understand it may fail"
ui_print " "
if $VKSEL; then
	ui_print "Clear for Google Pay: Yes"
	ui_print " "
	ui_print "Clearing caches for targetted apps..."
	for x in com.google.android.apps.walletnfcrel
		do 	pm clear $x >&2
		if [ $? -eq 0 ] ;	then
			ui_print "$x: cleared successfully" 
		else
			ui_print "$x: not cleared successfully" 	
		fi	
	done 	
else
	ui_print "Clear for Google Pay: No"	
fi
ui_print " "

# complete and card entry info
ui_print "Gpay Fix Install Complete"
ui_print " "
ui_print "You can now add your card to Google Pay and then reboot"
ui_print " "
sleep 2  
