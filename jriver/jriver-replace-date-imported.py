#!/usr/bin/env python3

import sys
import os

in_file = sys.argv[1]
out_file = sys.argv[2]

def getImportDate(line):
    date = line.lstrip('<Field Name="Date Imported">')
    date = date.rstrip('</Field>\n')
    return int(date)

def getCreateDate(line):
    date = line.lstrip('<Field Name="Date Modified">')
    date = date.rstrip('</Field>\n')
    return int(date)

f = open(in_file, "r")
lines = f.readlines()
f.close()

for lnum,line in enumerate(lines):
    if '<Field Name="Date Imported">' in line:
        import_date = getImportDate(line)
        date_imported_line = lnum
    elif '<Field Name="Date Modified">' in line:
        create_date = getCreateDate(line)
        if create_date < import_date:
            print(import_date, create_date)
            lines[date_imported_line] = f'<Field Name="Date Imported">{create_date}</Field>\n'    

f = open(out_file, 'w')
f_string = "".join(lines)
f.write(f_string)
f.close()
exit()