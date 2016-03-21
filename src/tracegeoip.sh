#!/bin/bash

#get output of traceroute in multi-line variable TRACE
TRACE="$( traceroute -n $1 )"

#loop through each line to parse every hop
while read line; do

#get only the first IP on the line
IP="$(echo $line | head -n 1 | grep -o '^[0-9]\+ [0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]*[0-9]*[0-9]' | grep -o -m1 '[0-9]\+\.[0-9]\+\.[0-9]\+\.[0-9]*[0-9]*[0-9]')"

#if the ip is not null, check if it's private or not
if [ ! -z "$IP" ]; then
echo $IP | grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)' &> /dev/null
ISPUBLIC=$?

#if ip is public, get the geoip data and store it in the multi-line variable GEOIPLOOKUPRESULT. Loop through the variable and store the country/city/province if present
if [[ $ISPUBLIC -eq 1 ]];then
GEOIPLOOKUPRESULT="$( geoiplookup $IP )"
while read geoline; do
MATCH="$(echo $geoline | grep 'GeoIP Country Edition:' | cut -f2 -d ':')"
if [ ! -z "$MATCH" ]; then
COUNTRY="$MATCH"
fi
MATCH="$(echo $geoline | grep 'GeoIP City Edition' | cut -f5 -d ',')"
if [ ! -z "$MATCH" ]; then
CITY=",$MATCH"
fi
MATCH="$(echo $geoline | grep 'GeoIP City Edition' | cut -f4 -d ',')"
if [ ! -z "$MATCH" ]; then
PROVINCE="-$MATCH"
fi
done <<< "$GEOIPLOOKUPRESULT"
GEOIPINFO="[$COUNTRY ] $PROVINCE $CITY"
else
GEOIPINFO="Private IP"
fi
echo "$line  $GEOIPINFO";
else
echo "$line";
fi
done <<< "$TRACE"

