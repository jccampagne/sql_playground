# rm -rf db

CLUSTER=db
initdb $CLUSTER
pg_ctl -D $CLUSTER -l logfile start

DBNAME=play
createdb $DBNAME

sleep 1

psql $DBNAME < schema.sql
