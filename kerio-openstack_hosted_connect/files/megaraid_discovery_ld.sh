#!/bin/bash
# maly (c) 2013
# configure this:
CLI=/opt/MegaRAID/MegaCli/MegaCli64

##############################################

allinfo=$($CLI -AdpAllInfo -aALL -NoLog)

adapters=$(echo -e "$allinfo" | egrep -i "adapter.*#[0-9]+" | cut -f2 -d'#')

echo -n "{
        \"data\":["

first=1

for adapter in $adapters; do

    ldlist=$($CLI -LDInfo -Lall -a$adapter -NoLog)

    echo -e "$ldlist" | awk '
       BEGIN { FS=":" }
       /^Virtual Drive/ { print strtonum($2) }
    ' | while read disk; do
         volume=$(echo -e "$disk")
        if [ $first = "1" ];
        then
                 printf "\n\t\t"
                 first=0
        else printf ",\n\t\t"
        fi
        echo -n "{ \"{#LV}\":\"$volume\", "
		echo -n " \"{#ADAPTER}\":\"$adapter\"}"
    done
done
echo "
        ]
}"

exit 0