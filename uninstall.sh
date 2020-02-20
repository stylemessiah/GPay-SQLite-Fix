# set payfixuninstall.log
logfile="/cache/payfixuninstall.log"

# wait till boot completed  - thanks to jcmm11
until [ "$(getprop sys.boot_completed)" = 1 ]
do
	sleep 1
done

echo "System boot completed" > $logfile
echo "" > $logfile

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
	echo "Database file dg.db....accessible" >> $logfile
	echo "" >> $logfile
    break;
fi
	sleep 1
done

# on to the main show............

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

# set default 660 permissions on dg.db
/system/bin/chmod 660 /data/data/com.google.android.gms/databases/dg.db
perms=$(stat -c %a /data/data/com.google.android.gms/databases/dg.db)
if [ $perms -eq 660 ] ; then
	echo "Chmod 660 command completed successfully" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
else
	echo "Chmod 660 command FAILED" >> $logfile
	echo "Permissions reported as: $perms" >> $logfile
	echo "" >> $logfile
fi
sleep 2


# Don't modify anything after this
if [ -f $INFO ]; then
  while read LINE; do
    if [ "$(echo -n $LINE | tail -c 1)" == "~" ]; then
      continue
    elif [ -f "$LINE~" ]; then
      mv -f $LINE~ $LINE
    else
      rm -f $LINE
      while true; do
        LINE=$(dirname $LINE)
        [ "$(ls -A $LINE 2>/dev/null)" ] && break 1 || rm -rf $LINE
      done
    fi
  done < $INFO
  rm -f $INFO
fi
