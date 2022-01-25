#!/bin/bash

email="[REDACTED]"
target_dir='/openils/var/web/filepile/discovery_layer_exports'
today=$(date +"%Y-%m-%d")
log_file="lbcc_marc_records.$today.log"

function send_via_ftp () {
    ftp -n $1 <<END_FTP
quote USER $2
quote PASS $3
binary
cd $4
put $5
quit
END_FTP
}

function send_records_to_ebsco () {
    filename="$target_dir/lbcc_marc_records.$today.mrc"
    host="ftp.epnet.com"
    user="[REDACTED]"
    password='[REDACTED]'
    remote_directory='full'

    /openils/bin/marc_export --descendants LINN --items -f USMARC -e UTF-8 >  $filename 2>> $log_file
    /openils/bin/marc_export --descendants LBCC --uris  -f USMARC -e UTF-8 >> $filename 2>> $log_file
    send_via_ftp $host $user $password $remote_directory $filename

    # For testing, perhaps you'd prefer to read some XML rather than binary MARC?
    #/openils/bin/marc_export --descendants LINN --items -f XML -e UTF-8 >  $target_dir/$filename 2>> $log_file
    #/openils/bin/marc_export --descendants LBCC --uris  -f XML -e UTF-8 >> $target_dir/$filename 2>> $log_file
    # For testing, get a quick count of how many records were exported using the XML export format
    #grep "controlfield tag=\"001\"" $target_dir/$filename | wc -l
}

function send_records_to_coutts () {
    filename="$target_dir/LINzz.$today.mrc"
    host="files.proquest.com"
    user="[REDACTED]"
    password='[REDACTED]'
    remote_directory='history'

    /openils/bin/marc_export --descendants LBCC -f USMARC -e UTF-8 > $filename 2>> $log_file
    send_via_ftp $host $user $password $remote_directory $filename
}

send_records_to_ebsco
send_records_to_coutts
cat $log_file | mail -s "Completed discovery layer export" $email
#rm $log_file
