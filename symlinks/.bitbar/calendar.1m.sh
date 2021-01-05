#!/bin/bash

# <bitbar.title>Calendar</bitbar.title>
# <bitbar.version>1.0</bitbar.version>
# <bitbar.author>Guilherme J. Tramontina</bitbar.author>
# <bitbar.author.github>gtramontina</bitbar.author.github>
# <bitbar.desc>Calendar</bitbar.desc>
# <bitbar.dependencies>bash</bitbar.dependencies>
# <bitbar.abouturl>https://github.com/gtramontina/</bitbar.abouturl>

menu_style=""

cal_font="courier new"
cal_size="12"
cal_color="black"
cal_style="trim=false font='$cal_font' size='$cal_size' color='$cal_color'"

# ---

echo "$(date +'%a %d %b')|$menu_style"
echo "---"


# #Comment out these lines to remove "last month"
# last_month=$(date -v-1m +%m)
# last_year=$(date -v-1m +%Y)
# last_month_name=$(date -jf %Y-%m-%d "$last_year"-"$last_month"-01 '+%b')
# echo "Prev: $last_month_name $last_year|trim=false font=$font"
# cal -d "$last_year"-"$last_month" |awk 'NF'|sed 's/ *$//'| while IFS= read -r i; do echo "--$i|trim=false font=$font"; done 
# echo "---"

cal -y -h | awk 'NF' | while IFS= read -r i; do echo " $i|$cal_style"; done

# |awk 'NF'|while IFS= read -r i; do echo " $i|$cal_style"|  perl -pe '$b="\b";s/ _$b(\d)_$b(\d) /(\1\2)/' |perl -pe '$b="\b";s/_$b _$b(\d) /(\1)/' |sed 's/ *$//'; done 

#Comment out these lines to remove "next month"
# echo "---"
# next_month=$(date -v+1m +%m)
# next_year=$(date -v+1m +%Y)
# next_month_name=$(date -jf %Y-%m-%d "$next_year"-"$next_month"-01 '+%b')
# echo "Next: $next_month_name $next_year|trim=false font=$font"
# cal -d "$next_year"-"$next_month" | awk 'NF'|sed 's/ *$//' | while IFS= read -r i; do echo "--$i|trim=false font=$font";done

