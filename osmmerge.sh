#!/bin/sh -eu
#
#  osmmerge -- Merges OSM files, with support for local not yet uploaded files
#
#  Copyright (c) 2019 Samuel Lidén Borell <samuel@kodafritt.se>
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#


tdir=$(mktemp -d --tmpdir osmmerge.XXXXXXXX)
echo "tempdir: $tdir"

last_osm_id() {
    grep -oEh 'id="[-0-9]+"' "$1" | tail -n 1 | grep -oE '[0-9]+' || true
}

offset=1
echo "Renumbering IDs..."
while [ $# != 0 ]; do
    nodecount=$(last_osm_id "$1")
    if [ -z "$nodecount" ] ; then
        shift
        continue
    fi
    echo "Using ID range $offset-$((offset + nodecount - 1)) for $1"
    if ! osmium renumber --start -$offset -o "$tdir/$offset.osm" "$1"; then
        echo "[!] File could not be renumbered, broken OSM file? $1 (with $nodecount IDs)" >&2
        rm "$tdir/$offset.osm"
        shift
        continue
    fi
    echo "Offset: $offset --> $((offset + nodecount))"
    offset=$((offset + nodecount))
    shift
done
echo "Merging..."
osmium merge -o "merged.osm" "$tdir"/*
echo "Done."
