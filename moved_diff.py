#!/usr/bin/env python3
#
#  moved_diff.py -- Cleans up moves/renames from diff files
#
#  Copyright (c) 2018 Samuel Lidén Borell <samuel@kodafritt.se>
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

import codecs, difflib, sys, unidiff

progresschars = 0

def progresschar(c):
    global progresschars
    sys.stderr.write(c)
    sys.stderr.flush()
    progresschars += 1

def get_stdin():
    #reader = codecs.getreader(sys.stdin.encoding)(sys.stdin)
    #reader = codecs.getreader('UTF-8')(sys.stdin)
    #reader.errors = 'surrogateescape'
    #return reader
    return open('/dev/stdin', 'r', errors='surrogateescape')

def get_stdout():
    return open('/dev/stdout', 'w', errors='surrogateescape')

#diffdata = sys.stdin.read()
#patch = unidiff.PatchSet(diffdata, encoding='binary')
patch = unidiff.PatchSet(get_stdin())
progresschar('>')
#print(dir(patch))
#print(patch.added_files)

def get_file_content(patchedfile):
    return "".join([line.value for line in patchedfile[0]])

files = []

added_files = list(patch.added_files)
removed_files = list(patch.removed_files)
# TODO skip all files with more than L lines, then iteratively increase L... but all files will have to be compared with all others (there could be a better match), so this won't work
# TODO using a kind of "bloom filter like" structure to skip comparing very dissimilar files could help.
# Start with files with few lines to rule them out quickly
#removed_files = sorted(removed_files, key=lambda file: len(file[0]))

# Starting with large files might be smarter...
added_files = sorted(added_files, key=lambda file: len(file[0]), reverse=True)
removed_files = sorted(removed_files, key=lambda file: len(file[0]), reverse=True)

addedcontents = []
for addedfile in added_files:
    addedcontents.append(get_file_content(addedfile))
progresschar('>')

removedcontents = []
for removedfile in removed_files:
    removedcontents.append(get_file_content(removedfile))
progresschar('>')

added_files = patch.added_files
for i, addedfile in enumerate(list(added_files)):
    ac = addedcontents[i]
    for j, removedfile in enumerate(list(removed_files)):
        rc = removedcontents[j]
        if addedfile is not None and removedfile is not None and ac == rc:
            diff = "--- "+addedfile.path+"\n+++ "+removedfile.path+"\n"
            files.append(diff)
            added_files[i] = None
            removed_files[i] = None
            progresschar('=')
progresschar('>')

for i, addedfile in enumerate(added_files):
    if addedfile == None:
        continue
    ac = get_file_content(addedfile)
    bestratio = 0
    bestrmpath = None
    bestrc = None
    bestindex = None
    #bestfile = None
    for j, removedfile in enumerate(removed_files):
        if removedfile == None:
            continue
        #rc = get_file_content(removedfile)
        rc = removedcontents[j]
        #if ac == rc:
        #    bestratio == 1
        #    bestrmpath = removedfile.path
        #    bestrc = rc
        #    bestindex = j
        #else:
        sm = difflib.SequenceMatcher(None, rc, ac)
        ratio = sm.real_quick_ratio()
        if ratio > bestratio:
            bestratio = ratio
            bestrmpath = removedfile.path
            bestrc = rc
            bestindex = j
            #bestfile = removedfile
            progresschar('+')
            if ratio > 0.995:
                break
        else:
            progresschar('.')
    sys.stderr.write(" [%02.1f%%] " % (100*i / len(patch.added_files)))
    sys.stderr.flush()
    if bestratio > 0.85:
        progresschars += 5+4
        #print("rc="+str(type(bestrc)) +"  ac="+str(type(ac)))
        #print("rp="+str(type(bestrmpath)) +"  ap="+str(type(addedfile.path)))
        rclines = bestrc.splitlines(True)
        aclines = ac.splitlines(True)
        #diff = difflib.unified_diff(bestrc, ac, bestrmpath, addedfile.path)
        diff = difflib.unified_diff(rclines, aclines, bestrmpath, addedfile.path)
        #sys.stdout.writelines(diff)
        #sys.exit(0)
        files.append(diff)
        removed_files[bestindex] = None

#if progresschars < 80:
sys.stderr.write("\b"*progresschars)
#else:
#    sys.stderr.write('\x1B[2J') # clear whole screen
separator = ("="*76) + "\n"
stdout = get_stdout()
for diff in files:
    stdout.write(separator)
    stdout.writelines(diff)
    #pass
stdout.write("\n")
#sys.stderr.write("%s --> %s  (%2.1f %%)\n" % (addedfile.path, bestfile.path, bestratio*100))
#print()

