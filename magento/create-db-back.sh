#!/bin/bash
echo "Enter path for local.xml (Only enter the application path, not the trailing /), followed by [ENTER]:"
read appath
path="$appath/app/etc/local.xml"
if [ -e "$path" ]
then
echo "Name of file (letsdump.sh is default, followed by [ENTER]:"
read file
echo "Do you want to change the name of your main backup directory? (myssql_backup is default), followed by [ENTER]:"
read backdir
backdir=${backdir:-mysql_backup}
file=${file:-letsdump.sh}
dbs=($(cat $path | grep -oP '(?<=<dbname><!\[CDATA\[)[^\]]+'))
host=($(cat $path | grep -oP '(?<=<host><!\[CDATA\[)[^\]]+'))
password=($(cat $path | grep -oP '(?<=<password><!\[CDATA\[)[^\]]+'))
user=($(cat $path | grep -oP '(?<=<username><!\[CDATA\[)[^\]]+'))
prefix=($(cat $path | grep -oP '(?<=<table_prefix><!\[CDATA\[)[^\]]+'))
echo $path
if [ ! -d "$HOME/$backdir/update" ]; then
mkdir -p $HOME/$backdir/update
fi
checkfile="$HOME/$backdir/$file"
if [ -e "$checkfile" ]; then
mv $HOME/$backdir/$file $HOME/$backdir/$file-bak-$(date +%d%m%Y_%H%M).bak
else
echo 'file doesnt exist'
fi
touch $HOME/$backdir/$file
touch $HOME/$backdir/update/clean-log.sql
echo "MAGEFILE=\"$dbs-\$(date +%d%m%Y_%H%M).sql.gz\"" >> $HOME/$backdir/$file
echo "mysql -p'$password' -u $user -h $host $dbs < update/clean-log.sql" >> $HOME/$backdir/$file
echo "mysqldump -p'$password' -u$user -h$host --single-transaction --quick $dbs | gzip > \$MAGEFILE" >> $HOME/$backdir/$file
echo "truncate $prefix dataflow_batch_export;truncate $prefix dataflow_batch_import;truncate $prefix log_customer;truncate $prefix log_quote;truncate $prefix log_summary;truncate $prefix log_summary_type;truncate $prefix log_url;truncate $prefix log_url_info;truncate $prefix log_visitor;truncate $prefix log_visitor_info;truncate $prefix log_visitor_online;truncate $prefix report_viewed_product_index;truncate $prefix report_compared_product_index;truncate $prefix report_event;truncate $prefix sendfriend_log;" > $HOME/$backdir/update/clean-log.sql
else
 echo "You really screwed up on the path, dude try this again. Did you screw up on the path? -->  $path"
fi
