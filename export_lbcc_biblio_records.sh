#!/bin/bash

dbname="db" #change this to appropriate value
username="user" #change this to appropriate value
email="sandbej at linnbenton dot edu" #change this to appropriate value
eg_version="2.9.1" #change this when we upgrade Evergreen

today=$(date +"%Y-%m-%d")
starting_dir=$(pwd)
filename="lbcc_marc_records.$today.mrc"
log_file="lbcc_marc_records.$today.log"


psql $dbname $username > $log_file << EOF
\o lbcc_tcns_to_export.old
  SELECT DISTINCT b.id as tcn
  FROM biblio.record_entry b
  INNER JOIN asset.call_number cn ON cn.record=b.id
  WHERE b.deleted=FALSE
  AND b.id != -1
  AND (cn.owning_lib=7
  AND cn.deleted=FALSE);
EOF

tail -n +2 lbcc_tcns_to_export.old > lbcc_tcns_to_export
rm lbcc_tcns_to_export.old
cd /home/opensrf/Evergreen-ILS-$eg_version/Open-ILS/src/support-scripts/ 2>> $starting_dir/$log_file
cat $starting_dir/lbcc_tcns_to_export | ./marc_export -i -c /openils/conf/opensrf_core.xml -x /openils/conf/fm_IDL.xml -f USMARC -e UTF-8 --timeout 5 > $starting_dir/eg_records_lbcc_findit.$today.mrc 2>> $starting_dir/$log_file
rm $starting_dir/lbcc_tcns_to_export
cat $starting_dir/$log_file | mail -s "Completed discovery layer export" $email
