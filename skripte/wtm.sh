#!/bin/bash

month=${1:-$(date +%m)}

year=${2:-$(date +%Y)}

current_date=$(date +%Y-%m-%d)

days_in_month=$(cal $month $year | awk 'NF {DAYS = $NF}; END {print DAYS}')

counter=1

for day in $(seq -w 1 $days_in_month); do
    iter_date="${year}-${month}-${day}"
    if [[ $iter_date > $current_date ]]; then
        break
    fi
    # 99 surves only to print deltas (covered in index.js)
    output=$(node ~/WorkTimer/index.js "${year}-${month}-${day}" 99 2> /dev/null)

    if [[ ! -z "$output" ]]; then
        printf "%02d: %s\n" $counter "$output"
        ((counter++))
    fi
done
