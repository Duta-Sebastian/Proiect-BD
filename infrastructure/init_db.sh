#!/bin/bash

sqlplus / as sysdba <<EOF
STARTUP;
EXIT;
EOF

echo $DB_PASSWD | sqlplus sys/ as sysdba @./setup.sql
echo "proiectbd" | sqlplus C##proiect/proiectbd @./dbinit.sql