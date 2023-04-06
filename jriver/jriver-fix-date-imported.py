#!/usr/bin/env python3

import sys
import os
from pathlib import PureWindowsPath

in_file = sys.argv[1]
out_file = sys.argv[2]

def getAlbumPath(line):
    filename = line.lstrip('<Field Name="Filename">')
    filename = filename.rstrip('</Field>\n')
    path = PureWindowsPath(filename)
    path = path.parents[0]
    return str(path)

def getDate(line):
    date = line.lstrip('<Field Name="Date Imported">')
    date = date.rstrip('</Field>\n')
    return int(date)


f = open(in_file, "r")
lines = f.readlines()
f.close()

albums = {}
for lnum,line in enumerate(lines):
    if '<Field Name="Filename">' in line:
        album = getAlbumPath(line)
    elif '<Field Name="Date Imported">' in line:
        date = getDate(line)
        if album in albums:
            albums[album].append((lnum, date))
        else:
            albums[album] = [(lnum, date)]

earliest = {}
for album in albums:
    tracks = albums[album]
    earliest_date = min(tracks, key = lambda t: t[1])[1]
    for track in tracks:
        lines[track[0]] = f'<Field Name="Date Imported">{earliest_date}</Field>\n'

f = open(out_file, 'w')
f_string = "".join(lines)
f.write(f_string)
f.close()
exit()