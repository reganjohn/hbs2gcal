#!/bin/bash

# Summary:
# --------
# This script allows a Mac user with iCal synced to their HBS Learning Hub 
# calendar to combine all the individual ICS files into one large .ics file 
# for upload into Google Calendar.
#
# Author: 
# -------
# John Regan 
# MBA 2016
# Harvard Business School
#
# Instructions:
# -------------
# * The output file is a file path.
# * The user can choose to print event titles to the screen.
# * The user can choose to include only events in 2015.
#
# Disclaimer:
# -----------
# The code is provided "as is" and any express or implied warranties, 
# including the implied warranties of merchantability and fitness for a 
# particular purpose are disclaimed. In no event shall John Regan be liable 
# for any direct, indirect, incidental, special, exemplary, or consequential 
# damages (including, but not limited to, procurement of substitute goods or 
# services; loss of use, data, or profits; or business interruption) 
# sustained by you or a third party, however caused and on any theory of 
# liability, whether in contract, strict liability, or tort arising in any 
# way out of the use of this sample code, even if advised of the possibility 
# of such damage.

# ask the user for the output file
while true; do
    read -p "Output .ics file: " ofile
    # be sure the file could actually be created
    if [[ -d `dirname $ofile` ]]; then
        break
    else
        echo "This directory does not exist. Try again, or Ctrl-c to quit."
    fi
done

# fetch the first directory containing an .ics file with 'inside.hbs.edu' in it
# this is assumed to be the directory containing all subscribed HBS calendar events 
icsdir=$(dirname $(grep -lr 'inside.hbs.edu' /Users/$USER/Library/Calendars/ | head -1))

# ask the user if event summaries should be printed the the screen
PS3="Print event titles? "
options=("Yes" "No" "Quit")
select yn in "${options[@]}"; do
    case $yn in
        Yes ) showsumm=true; break;;
        No )  showsumm=false; break;;
        Quit ) exit;;
        * ) echo "Enter '1' for Yes, '2' for No, '3' to Quit";;
    esac
done
echo ""

# ask the user if only events from 2015 should be included
PS3="Include only events in 2015? "
options=("Yes" "No" "Quit")
select yn in "${options[@]}"; do
    case $yn in
        Yes ) only2015=true; break;;
        No )  only2015=false; break;;
        Quit ) exit;;
        * ) echo "Enter '1' for Yes, '2' for No, '3' to Quit";;
    esac
done

echo "
Combining ICS files..."

if $showsumm; then
    echo ""
    echo "ICS summaries below:"
    echo ""
fi

# print the header rows
echo "BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Apple Inc.//iCal 4.0.4//EN 
CALSCALE:GREGORIAN" > $ofile

# loop through all HBS ics files
counter=0
while read -r filename; do
    # if only include 2015 events and event not in 2015, continue
    if $only2015 && ! grep -q '^DTSTART.*:2015' $filename; then
        continue
    fi

    counter=$((counter+1))
    
    # if user wants summaries printed, do so
    if $showsumm; then
        grep '^SUMMARY:' $filename | sed -e 's/^SUMMARY:\(.*\)\\n/\1/'
    fi
    
    # paste event body content into output file
    grep -v 'VCALENDAR\|VERSION\|PRODID\|CALSCALE' $filename >> $ofile

# only include events that have "inside.hbs.edu" in them, just to be safe
done < <(grep -l 'inside.hbs.edu' $icsdir/*.ics)

echo "END:VCALENDAR" >> $ofile

echo "
Wrote $counter events to $ofile
"
