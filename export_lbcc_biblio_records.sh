#!/bin/bash

email="[REDACTED]"
target_dir='/openils/var/web/filepile/discovery_layer_exports'
today=$(date +"%Y-%m-%d")
filename="lbcc_marc_records.$today.mrc"
log_file="lbcc_marc_records.$today.log"
host="ftp.epnet.com"
user="[REDACTED]"
password='[REDACTED]'
remote_directory='full'


/openils/bin/marc_export --descendants LINN --items -f USMARC -e UTF-8 >  $target_dir/$filename 2>> $log_file
/openils/bin/marc_export --descendants LBCC --uris  -f USMARC -e UTF-8 >> $target_dir/$filename 2>> $log_file

# FTP the records to the remote server
ftp -n $host <<END_FTP
quote USER $user
quote PASS $password
binary
cd $remote_directory
put $target_dir/$filename
quit
END_FTP

# For testing, perhaps you'd prefer to read some XML rather than binary MARC?
#/openils/bin/marc_export --descendants LINN --items -f XML -e UTF-8 >  $target_dir/$filename 2>> $log_file
#/openils/bin/marc_export --descendants LBCC --uris  -f XML -e UTF-8 >> $target_dir/$filename 2>> $log_file

cat $log_file | mail -s "Completed discovery layer export" $email

#rm $log_file
# For testing, get a quick count of how many records were exported using the XML export format
#grep "controlfield tag=\"001\"" $target_dir/$filename | wc -l