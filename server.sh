#!/bin/bash
# chmod 755 server.sh
# run ./server.sh
#open browser, visit http://localhost:8080

RESP=/tmp/webresp
[ -p $RESP ] || mkfifo $RESP

while true ; do

( cat $RESP ) | nc -lv 8080 2>con.ip | (
        REQ=`while read L && [ " " "<" "$L" ] ; do echo "$L" ; done`
        url="${REQ#GET }"
        url="${url% HTTP/*}"
        conip=$(tail -1  con.ip | cut -d'[' -f 2 | cut -d']' -f 1)
        echo "$conip [`date '+%Y-%m-%d %H:%M:%S'`] $REQ" | head -1 >> server.log 2>&1 | echo "$conip [`date '+%Y-%m-%d %H:%M:%S'`] $url"

        #split get into filename, arguments
        url=(${url//\?/ })
        cwd=$(pwd)
        file="${url[0]}"
        if [ "$file" == "/" ]; then
           file="index.html"
        fi

        filename="$cwd/www$file"

        #if there is a file
        if [ -f "$filename" ]; then
        #if html, set conten type html, otherwise read file mime
           if [[ "$file" == *.html ]] || [[ "$file" == *.htm ]] || [[ "$file" == *.php ]] || [[ "$file" == *.py ]] || [[ "$file" == *.cb ]] || [[ "$file" == *.ph7 ]]
           then
                ctype="text/html"
           else
             cat "$filename" >$RESP
             continue
           #      ctype=$(file --mime-type $filename)
           #      echo "$ctype - $filename"
           #      ctype=${ctype#* }
           fi

           #list arguments - to pass on to pyton or C
           if [ "${#url[@]}" -gt 1 ]; then
                arg=${url[1]}
                cont=""
                getarg=(${url[1]//\&/ })
                for x in ${getarg[@]}
                do
                  cont="$cont $x"
                done

           fi
           #end argument list

           #if ph7, PHP, Python script or binary, process it & show the result to the user, otherwise, just output the file
           filedata=""
           executefile=${url[0]#*/}
           #execute C, Python and PHP scripts
           if [[ "$file" == *.cb ]]; then
                filedata=$(cd www && ./$executefile $cont)
           elif [[ "$file" == *.php ]]; then
                filedata=$(php $filename $cont)
           elif [[ "$file" == *.ph7 ]]; then
                filedata=$(./ph7 $filename $cont)
           elif [[ "$file" == *.py ]]; then
                filedata=$(python $filename $cont)
           else
                filedata=$(<$filename)
           fi
           # Content-Length: ${#filedata}
           TRES="HTTP/1.1 200 OK
Date: `date '+%a, %d %b %Y %T %Z'`
Cache-Control: private
Server: NCbash/2.3
Accept-Ranges: bytes
Content-Type: $ctype
Connection: close
Content-Length: ${#filedata}
Content-Encoding: binary

$filedata"
        else
           TRES="HTTP/1.1 404 Not Found
Content-Type: text/html

<h1>404 Not Found</h1>
The requested resource was not found"
        fi

cat >$RESP <<EOF
$TRES
EOF
)
done
