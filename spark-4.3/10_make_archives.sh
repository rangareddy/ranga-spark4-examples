#!/usr/bin/env bash
# Builds the archives that 10_archive_reader.sql reads. Run it from the directory you run the SQL from.
set -euo pipefail
command -v zip >/dev/null || { echo 'zip is required' >&2; exit 1; }
rm -rf arc && mkdir arc && cd arc
printf 'id,name\n1,ana\n2,bob\n' > a.csv
printf 'id,name\n3,cy\n' > b.csv
printf 'id,name\n9,notes\n' > notes.txt   # a non-target entry that has a data row
tar -cf data.tar a.csv b.csv notes.txt
zip -q data.zip a.csv b.csv
rm a.csv b.csv notes.txt
ls -l
