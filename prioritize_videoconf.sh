#!/bin/sh -eu
#
#  prioritize_videoconf -- Sets process niceness (priority) for video conferencing
#
#  Copyright (c) 2021 Samuel Lidén Borell <samuel@kodafritt.se>
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

user=jitsi

pids=$(pgrep --uid "$user" pulseaudio || true
       pgrep --uid "$user" 'Web Content' || true
       pgrep --uid "$user" 'Isolated Web Co' || true
       pgrep --uid "$user" 'Socket Process' || true
       pgrep --uid "$user" firefox-bin || true
       pgrep --uid "$user" 'Privileged Con' || true
       pgrep --uid "$user" chromium || true
       pgrep --uid "$user" zoom || true
       pgrep Xorg || true
      )
echo "Re-nicing $pids"
sudo renice -n -5 -p $pids
sudo renice -n -2 -p $(pgrep Xorg)
#sudo ionice -c 2 -n 0 -p $pids
sudo ionice -c 1 -n 0 -p $pids
echo "Done."
