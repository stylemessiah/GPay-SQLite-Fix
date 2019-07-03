#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}



#  find sdcard
if [ -d /sdcard ] ; then
    sdcardpath=/sdcard
elif [ -d /storage/emulated/0 ] ; then
    sdcardpath=/storage/emulated/0
else
	echo "sdcard not found"
fi

# set logfile
logfile=$sdcardpath/payfixfirstrun.log

# checking for existing payfixfirstrun.log file - only want it to log once on install
if [ ! -f $logfile ] ; then
	touch $sdcardpath/payfixfirstrun.log
	
	# check where sqlite is
	if [ -f /data/data/com.termux/files/usr/lib/sqlite3 ] ; then
		sqlpath=/data/data/com.termux/files/usr/lib
		echo 'SQLite3 binary found in: $sqlpath' >> $logfile
	elif [ -f /system/bin/sqlite3 ] ; 	then
		sqlpath=/system/bin
		echo 'SQLite3 binary found in: $sqlpath' >> $logfile
	elif [ -f /system/xbin/sqlite3 ] ; then
		sqlpath=/system/xbin
		echo 'SQLite3 binary found in: $sqlpath' >> $logfile
	else 
		echo 'SQLite3 binary not found, please install a SQLite3 binary, without this the fix may not work'  >> $logfile
	fi
	sleep 2

	# check where chattr is
	if [ -f /data/data/com.termux/files/usr/bin/applets/chattr ] ; then
		chattrpath=/data/data/com.termux/files/usr/bin/applets
		echo 'Chattr binary found in: $chattrpath' >> $logfile
	elif [ -f /system/bin/chattr ] ; then 
		chattrpath=/system/bin
		echo 'Chattr binary found in: $chattrpath' >> $logfile
	elif [ -f /system/xbin/chattr ] ; then 
		chattrpath=/system/xbin
		echo 'Chattr binary found in: $chattrpath' >> $logfile
	else 
		echo 'Chattr binary not found, please install BusyBox, without this the fix may not work' >> $logfile
	fi
	sleep 2

	# on to the main show the SQL commands and database permissions
	/system/bin/am force-stop /data/data/com.google.android.apps.walletnfcrel

	if [ $? -eq 0 ]
	then
		echo "Google Pay stopped successfully"
	else
		echo "Google Pay NOT stopped successfully"
	fi
	sleep 2

	# undo dg.db immutability
	$chattrpath/chattr -i /data/data/com.google.android.gms/databases/dg.db

	if [ $? -eq 0 ]
	then
		echo "Chattr -i command completed successfully"
	else
		echo "Chattr command FAILED"
	fi
	sleep 2

	# set 777 permissions on dg.db
	/system/bin/chmod 777 /data/data/com.google.android.gms/databases/dg.db

	if [ $? -eq 0 ]
	then
		echo "Chmod 777 command completed successfully"
	else
		echo "Chmod command FAILED"
	fi
	sleep 2

	# run sqlite 3 commands on dg.db
	$sqlpath/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"

	if [ $? -eq 0 ]
	then
		echo "SQLite3 command completed successfully"
	else
		echo "SQLite3 command FAILED"
	fi
	sleep 2
	
	# set 440 permissions on dg.db
	/system/bin/chmod 440 /data/data/com.google.android.gms/databases/dg.db

	if [ $? -eq 0 ]
	then
		echo "Chmod 440 command completed successfully"
	else
		echo "Chmod command FAILED"
	fi
	sleep 2
	
	# make dg.db file immutable
	$chattrpath/chattr +i /data/data/com.google.android.gms/databases/dg.db

	if [ $? -eq 0 ]
	then
		echo "Chattr +i command completed successfully"
	else
		echo "Chattr command FAILED"
	fi

fi

exit