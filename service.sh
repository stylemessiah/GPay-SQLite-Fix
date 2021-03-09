(
#!/system/bin/sh
# Do NOT assume where your module will be located.
# ALWAYS use $MODDIR if you need to know where this script
# and module is placed.
# This will make sure your module will still work
# if Magisk change its mount point in the future
MODDIR=${0%/*}

# set script to run SQL commands
runsql=1

# set logfile variable
logfile="/cache/payfixfirstrun.log"

# wait till boot completed  - thanks to jcmm11
until [ "$(getprop sys.boot_completed)" = 1 ]
do
	sleep 1
done

echo "System boot completed" > $logfile
echo "" >> $logfile

while (true); do
if [ -f "/system/bin/chmod" ]; then
	echo "/system/bin/chmod....accessible" >> $logfile
	echo "" >> $logfile
    break;
fi
	sleep 1
done

# check the dg.db file is accessible before we start off doing anything - thanks to didgeridoohan
while (true); do
if [ -f "/data/data/com.google.android.gms/databases/dg.db" ]; then
	echo "/data/data/com.google.android.gms/databases/dg.db....accessible" >> $logfile
	echo "" >> $logfile
    break;
fi
	sleep 1
done


# check where sqlite is
if [ -f /data/data/com.termux/files/usr/bin/sqlite3 ] ; then
	sqlpath=/data/data/com.termux/files/usr/bin
	echo "[termux] SQLite3 binary found in: $sqlpath" >> $logfile
	echo "" >> $logfile
elif [ -f /data/data/com.keramidas.TitaniumBackup/files/sqlite3 ] ; then
	sqlpath=/data/data/com.keramidas.TitaniumBackup/files
	echo "[titanium] SQLite3 binary found in: $sqlpath" >> $logfile
	echo "" >> $logfile	
elif [ -f /system/bin/sqlite3 ] ; then
	sqlpath=/system/bin
	echo "[standard] SQLite3 binary found in: $sqlpath" >> $logfile
	echo "" >> $logfile
elif [ -f /system/xbin/sqlite3 ] ; then
	sqlpath=/system/xbin
	echo "[standard] SQLite3 binary found in: $sqlpath" >> $logfile
	echo "" >> $logfile
else 
	echo "SQLite3 binary not found, please install a SQLite3 binary, without this the fix *may* not work" >> $logfile
	echo "I provide an SQLite3 Universal Binary Magisk Module, and links to SQLite3 binaries for other architectures" >> $logfile
	echo "at https://forum.xda-developers.com/showpost.php?p=79643248&postcount=176" >> $logfile
	echo "" >> $logfile
fi
sleep 2


# stop Google Pay
/system/bin/am force-stop /data/data/com.google.android.apps.walletnfcrel
if [ $? -eq 0 ] ; then
	echo "Google Pay stopped successfully" >> $logfile
	echo "" >> $logfile
else
	echo "Google Pay NOT stopped successfully" >> $logfile
	echo "" >> $logfile
fi
sleep 2

if [ $runsql -eq 1 ] ; then
# set 777 permissions on dg.db
/system/bin/chmod 777 /data/data/com.google.android.gms/databases/dg.db
perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
if [ $perms -eq 777 ]; then
	echo "Chmod 777 command completed successfully" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
else
	echo "Chmod command FAILED" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
fi
sleep 2
	
# run sqlite 3 commands on dg.db
$sqlpath/sqlite3 /data/data/com.google.android.gms/databases/dg.db "update main set c='0' where a like '%attest%';"
if [ $? -eq 0 ] ; 	then
	echo "SQLite3 command completed successfully" >> $logfile
	echo "" >> $logfile
else
	echo "SQLite3 command FAILED" >> $logfile
	echo "" >> $logfile
fi
sleep 2
fi
		
# set 440 permissions on dg.db
/system/bin/chmod 440 /data/data/com.google.android.gms/databases/dg.db
perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
if [ $perms -eq 440 ] ; then
	echo "Chmod 440 command completed successfully" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
else
	echo "Chmod command FAILED" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
fi
sleep 2
) &
