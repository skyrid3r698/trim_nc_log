#!/bin/bash

#variables
x="360" #number of days to work through
logdir="/home/sky"
logfile="nextcloud.log"
workdir="/tmp"
echo trimming last $x days of $logdir/$logfile
cp $logdir/$logfile $workdir/
#trim everything before time of each line
echo trimming everything infront of time and date of $logdir/$logfile
sed -i 's/^.*time":"/'/ $workdir/$logfile
#trim everything except last x days of log entries
#read each day and append it to a file
if test -f "$workdir/tempx.txt"; then
    rm $workdir/tempx.txt
fi
echo working through $x days and write it to a temporary file: $workdir/tempx.txt
while [ $x -gt -1 ];
do
XOLD=`(date +"%Y-%m-%d"  --date="$x days ago")`
let x--
cat $workdir/$logfile | grep "$XOLD" >> $workdir/tempx.txt
done
echo set temporary file as new $workdir/$logfile
mv $workdir/tempx.txt $workdir/$logfile

########failed logins############
echo creating $workdir/failedlogins.txt and moving it to current directory
#delete every line without "Login failed"
sed '/Login failed/!d' $workdir/$logfile > $workdir/failedlogins.txt
#delete everything between "user": and message including "user":
sed -i 's/"user":.*message/"message'/ $workdir/failedlogins.txt
#delete everything after version of each line
sed -i 's/"."version.*//g' $workdir/failedlogins.txt
#delete every instance of '
sed -i "s/'//g" $workdir/failedlogins.txt
mv $workdir/failedlogins.txt ./

###########unique ips###########
echo creating $workdir/uniqueip.txt and moving it to current directory
#delete every line without "remoteAddr"
sed '/remoteAddr/!d' $workdir/$logfile > $workdir/uniqueip.txt
#remove every line with ajax in it
sed -in '/ajax/d' $workdir/uniqueip.txt
#trim everything before remoteAddr":" of each line
sed -i 's/^.*remoteAddr":"/'/ $workdir/uniqueip.txt
#delete everything after Remote IP of each line
sed -i 's/","user.*//g' $workdir/uniqueip.txt
#delete empty lines
sed -i '/^$/d' $workdir/uniqueip.txt
# sortieren
sort $workdir/uniqueip.txt | uniq -c | sort -nr > $workdir/temp.txt
mv $workdir/temp.txt uniqueip.txt

###########unique names###########
echo creating $workdir/uniquenames.txt and moving it to current directory
#delete every line without "remoteAddr"
sed '/remoteAddr/!d' $workdir/$logfile > $workdir/uniquenames.txt
#remove every line with ajax in it
sed -in '/ajax/d' $workdir/uniquenames.txt
#trim everything before user":" of each line
sed -i 's/^.*user":"/'/ $workdir/uniquenames.txt
#delete everything after Remote IP of each line
sed -i 's/","app.*//g' $workdir/uniquenames.txt
#delete empty lines
sed -i '/^$/d' $workdir/uniquenames.txt
# sortieren
sort $workdir/uniquenames.txt | uniq -c | sort -nr > $workdir/temp2.txt
mv $workdir/temp2.txt uniquenames.txt
