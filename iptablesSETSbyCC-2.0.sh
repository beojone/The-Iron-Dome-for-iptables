#!/usr/bin/env bash
comeca () {
        clear
        echo -e "\nCreating rules to block: ${@^^}\n"
        for i in $@
        do

         echo $i | grep -Ei "TOR" > /dev/null 2>&1
         [ $? -eq 0 ] && torblocker $i && continue

         echo $i | grep -Ei "gd|py|co|ve|cl|sr|bo|ec|gf|ar|gy|br|pe|uy|fk" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i lacnic && continue

         echo $i | grep -Ei "SX|BQ|CW|AG|AI|AN|AW|BB|BL|BM|BS|BZ|CA|CR|CU|DM|DO|GD|GL|GP|GT|HN|HT|JM|KN|KY|LC|MF|MQ|MS|MX|NI|PA|PM|PR|SV|TC|TT|US|VC|VG|VI" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i arin && continue

         echo $i | grep -Ei "AE|AF|AM|AP|AZ|BD|BH|BN|BT|CC|CN|CX|CY|GE|HK|ID|IL|IN|IO|IQ|IR|JO|JP|KG|KH|KP|KR|KW|KZ|LA|LB|LK|MM|MN|MO|MV|MY|NP|OM|PH|PK|PS|QA|SA|SG|SY|TH|TJ|TL|TM|TW|UZ|VN|YE" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i apnic && continue

         echo $i | grep -Ei "AO|BF|BI|BJ|BW|CD|CF|CG|CI|CM|CV|DJ|DZ|EG|EH|ER|ET|GA|GH|GM|GN|GQ|GW|KE|KM|LR|LS|LY|MA|MG|ML|MR|MU|MW|MZ|NA|NE|NG|RE|RW|SC|SD|SH|SL|SN|SO|ST|SZ|TD|TG|TN|TZ|UG|YT|ZA|ZM|ZW" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i afrinic && continue

         echo $i | grep -Ei "AD|AL|AT|AX|BA|BE|BG|BY|CH|CZ|DE|DK|EE|ES|EU|FI|FO|FR|FX|GB|GG|GI|GR|HR|HU|IE|IM|IS|IT|JE|LI|LT|LU|LV|MC|MD|ME|MK|MT|NL|NO|PL|PT|RO|RS|RU|SE|SI|SJ|SK|SM|TR|UA|VA" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i ripencc && continue

         echo $i | grep -Ei "AS|AU|CK|FJ|FM|GU|KI|MH|MP|NC|NF|NR|NU|NZ|PF|PG|PN|PW|SB|TK|TO|TV|UM|VU|WF|WS" > /dev/null 2>&1
         [ $? -eq 0 ] && baixaefiltra $i apnic && continue



        done
}

torblocker() {
        a=${1^^}
        echo -e "\nBlocking $a"

        curl -sSL "https://check.torproject.org/cgi-bin/TorBulkExitList.py?ip=$(curl icanhazip.com)" | sed '/^#/d' > tornets.txt

        ipset create "$a-net" hash:ip 2>/dev/null
        ipset flush "$a-net"

        while IFS= read -r iptor;
        do
        ipset add "$a-net" $iptor
        done < tornets.txt

        iptables -t filter -I INPUT -m set --match-set "$a-net" src -j DROP

rm tornets.txt 2>/dev/null
}

baixaefiltra () {
        a=${1^^}
        echo -e "\nBlocking $a"

        lacnic="http://ftp.lacnic.net/pub/stats/lacnic/delegated-lacnic-extended-latest"
        arin="https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest"
        apnic="https://ftp.apnic.net/stats/apnic/delegated-apnic-extended-latest"
        afrinic="http://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-extended-latest"
        ripencc="http://ftp.ripe.net/pub/stats/ripencc/delegated-ripencc-extended-latest"

        #echo delegated-$2-extended-latest
        #echo ${!2}

        [ -f delegated-$2-extended-latest ] ||  { echo "Downloading reference file"; wget --quiet ${!2} ; } || { echo "Could not receive reference file, check internet connection"; exit 33; }

        grep -F $(echo ${a^^}) delegated-$2-extended-latest | grep -Fv -e asn -e ipv6 -e allocated | sed 's/|/ /g' | awk '{print $4,$5}' > ipv4$a
	
	
	while IFS=' ' read -r netadd cidr 
		do 

		pcidr=(2 4 8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216)
		printf '%s\n' "${pcidr[@]}" | grep -x -q "$cidr" || { echo "$netadd $cidr - invalid CIDR notation" >> $a-invalids.txt; b=1; continue; }
	
		echo $cidr >> cidrs.txt
		echo $netadd >> addrs.txt

	done < ipv4$a
	
	sed cidrs.txt  -e 's/\<2\>/\/31/' -e 's/\<4\>/\/30/' -e 's/\<8\>/\/29/' -e 's/\<16\>/\/28/'  -e 's/\<32\>/\/27/'  -e 's/\<64\>/\/26/' -e 's/\<128\>/\/25/' -e 's/256/\/24/' -e 's/512/\/23/' -e 's/1024/\/22/' -e 's/2048/\/21/' -e 's/4096/\/20/' -e 's/8192/\/19/' -e 's/16384/\/18/' -e 's/32768/\/17/' -e 's/65536/\/16/' -e 's/131072/\/15/' -e 's/262144/\/14/' -e 's/524288/\/13/' -e 's/1048576/\/12/' -e 's/2097152/\/11/' -e 's/4194304/\/10/' -e 's/8388608/\/9/' -e 's/16777216/\/8/' >> cidrs2.txt

	paste addrs.txt cidrs2.txt | tr -d '[:blank:]' > Redes$a.txt
	rm cidrs.txt addrs.txt cidrs2.txt ipv4$a

	[[ $b -eq 1 ]] && echo -e "\nPlease check $a-invalids.txt for networks that require attention\n"
	unset b

	criaset $a
}

criaset () {
        a=${1^^}
        echo "Creating an ipset to $a"

        ipset create "$a-net" hash:net 2>/dev/null
        ipset flush "$a-net"

        while IFS= read -r rede; do
                ipset add "$a-net" $rede
        done < Redes$a.txt

        rm Redes$a.txt

        iptables -t filter -I INPUT -m set --match-set "$a-net" src -j DROP

        echo "$a blocked"
}

delset () {

        for i in ${@:2}
        do

        a=${i^^}
        echo "Removing $a from block list"

        iptables -t filter -D INPUT -m set --match-set "$a-net" src -j DROP
        ipset destroy "$a-net"

        done
        echo "Blocks removed for: ${@:2}"

}

verifica () {

        for i in ${@^^}
        do
                [[ $i == "--DEL" ]] || [[ $i == "TOR" ]] && continue
                [[ $(echo -n $i | wc -c) -gt 2 ]] && { echo "$i excede o número de caracteres"; maior=1; }
                [[ $(echo -n $i | wc -c) -le 1 ]] && { echo "$i argumento incompleto"; menor=1; }

done
[[ $maior -eq 1 ]] && exit 42
[[ $menor -eq 1 ]] && exit 42
}

[[ $(which ipset) ]] || { clear; echo -e "\n\nIPSet not found\n\n" ; exit 33; }
[[ $1 ]] && verifica $@
[[ $1 == "--del" ]] || [[ $1 == "--DEL" ]] && delset $@ && exit 0
[[ $1 ]] && comeca $@ || { clear; echo -e "To create a set or sets: $0 CN BR AU\n\nTo remove a set or sets: $0 --del CN BR AU tor\n\nTOR should always come first when creating set if thats the case, ex: $0 tor cn br...\n" ; exit 33; }

rm delegated-ripencc-extended-latest delegated-afrinic-extended-latest delegated-apnic-extended-latest delegated-arin-extended-latest delegated-lacnic-extended-latest 2>/dev/null

