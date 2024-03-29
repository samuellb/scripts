#!/bin/sh -eu
#
#  low_battery -- Shows a low battery warning when started
#
#  Copyright (c) 2020 Samuel Lidén Borell <samuel@kodafritt.se>
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

time=60000
capacity=$(cat /sys/class/power_supply/BAT0/charge_full)
charge=$(cat /sys/class/power_supply/BAT0/charge_now)
percentage=$((100 * charge / capacity))
echo "percentage: $percentage"

#percentage=9

if [ "$percentage" -lt 10 ]; then
    notify-send "Critical battery level: $percentage%" --icon=battery-caution -u critical -t $time -h string:x-canonical-private-synchronous:battery
else
    notify-send "Battery level: $percentage%" --icon=battery-low -u normal -t $time -h string:x-canonical-private-synchronous:battery
fi
