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

    pdlist=$($CLI -PDList -a$adapter -NoLog)

    echo -e "$pdlist" | awk '
       BEGIN { FS=":" }
       /Enclosure Device ID/ { enclosure=strtonum($2) }
       /Slot Number/ { print enclosure":"strtonum($2) }
    ' | while read disk; do
         enclosure=$(echo -e "$disk" | cut -f1 -d':')
         diskid=$(echo -e "$disk" | cut -f2 -d':')
        if [ $first = "1" ];
        then
                 printf "\n\t\t"
                 first=0
        else printf ",\n\t\t"
        fi
        echo -n "{ \"{#ENC}\":\"$enclosure\", "
        echo -n "\"{#DISK}\":\"$diskid\", "
        echo -n " \"{#ADAPTER}\":\"$adapter\"}"
    done
done
echo "
        ]
}"

exit 0