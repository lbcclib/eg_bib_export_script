#!/bin/bash

dbname="db"
username="user"
today=$(date +"%Y-%m-%d")
starting_dir=$(pwd)
filename="lbcc_marc_records.$today.mrc"


psql $dbname $username << EOF
\o lbcc_tcns_to_export.old
SELECT  DISTINCT b.id as tcn
  FROM biblio.record_entry b
  INNER JOIN asset.call_number cn ON cn.record=b.id
  INNER JOIN asset.copy c ON c.call_number=cn.id
  WHERE b.deleted=FALSE
  AND b.id != -1
  AND (c.circ_lib=7
    AND c.deleted=FALSE)
  OR xpath_exists('//m:datafield[@tag="856"]/m:subfield[@code="9" and text()="LBCC"]', b.marc::xml, ARRAY[ARRAY['m','http://www.loc.gov/MARC21/slim']]);
EOF

tail -n +2 lbcc_tcns_to_export.old > lbcc_tcns_to_export
rm lbcc_tcns_to_export.old
cd /home/opensrf/Evergreen-ILS-2.7.4/Open-ILS/src/support-scripts/
cat $starting_dir/lbcc_tcns_to_export | ./marc_export -i -c /openils/conf/opensrf_core.xml -x /openils/conf/fm_IDL.xml -f USMARC --timeout 5 > $starting_dir/eg_records_lbcc_findit.$today.mrc
rm $starting_dir/lbcc_tcns_to_export
