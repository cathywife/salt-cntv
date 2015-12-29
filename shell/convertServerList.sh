file="../data/saltServersList.csv"

function convf()
{
	echo "$1:"
	cat $file |grep -v "^#\|^#" |awk -F, '{print $1" "$'$2'}' |while read ip rows
	do
		echo "  {% if grains['id'] == \"$ip\" %}"
		echo $rows |sed "s/\;/ /g" |while read -a row
		do
			for p in "${row[@]}"
			do
				if [  "$1" == "roles" ]
				then
					p1=""
					echo $p |sed "s/-/\n/g" |while read line; do p1="$p1-$line"; echo "    - $p1" |sed "s/- -/- /g" >> /tmp/res; done;
				else
					echo "    - $p"
				fi
			done
			if [  "$1" == "roles" ]
			then
				cat /tmp/res 2> /dev/null |sort |uniq
				rm -f /tmp/res
			fi
		done
		echo -e "  {% endif %}\n"
	done
}

function makeList()
{
	rm -f ./lists/*.role.list
	cat $file |grep -v "^#\|^#" |awk -F, '{print $3}' |sed 's/;/\n/g' |sort |uniq |grep -v "^$" |while read role
	do
		#echo $role
		> ./lists/$role.role.list
		cat $file |grep -v "^#\|^#" |awk -F, '{print $1" "$3}'|grep "${role};\|${role}$" |while read ip roles
		do
			echo $ip >> ./lists/$role.role.list
		done
	done
}

for i in `seq 2 50`
do
	item=`cat $file |head -n 1 |awk -F, '{print $'$i'}'`
	if [ `echo "$item" |grep "^EndOfLine"` ]
	then
		break
	fi
	echo "converting $item ..."
	convf $item $i > ../pillar/.${item}.sls.tmp
	mv ../pillar/.${item}.sls.tmp ../pillar/${item}.sls
done
makeList
