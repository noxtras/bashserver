#!/bin/bash
# web.sh -- http://localhost:8080/index.html
# chmod 755 server.sh
# then run: ./server.sh

RESP=/tmp/webresp
[ -p $RESP ] || mkfifo $RESP

while true ; do

( cat $RESP ) | nc -l -p 8080 | (
REQ=`while read L && [ " " "<" "$L" ] ; do echo "$L" ; done`
url="${REQ#GET }"
url="${url% HTTP/*}"
echo "[`date '+%Y-%m-%d %H:%M:%S'`] $REQ" | head -1 >> server.log 2>&1 | echo "[`date '+%Y-%m-%d %H:%M:%S'`] $url"

#split get into filename, arguments
url=(${url//\?/ })
filename="/home/george${url[0]}"

#if there is a file
if [ -f "$filename" ]; then
#if html, set conten type html, otherwise read from file(needed for Firefox)
if [[ "${url[0]}" == *.html ]] || [[ "${url[0]}" == *.htm ]] || [[ "${url[0]}" == *.php ]] || [[ "${url[0]}" == *.py ]] || [[ "${url[0]}" == *.cb ]]
        then
          ctype="text/html"
        else
          ctype=$(file --mime-type $filename)
          ctype=${ctype#* }
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

#if PHP or Python script or binary, process it, show the result to the user, otherwise, just output the file
filedata=""
executefile=${url[0]#*/}
#execute C, Python and PHP scripts
if [[ "${url[0]}" == *.cb ]]; then
        filedata=$(./$executefile $cont)
elif [[ "${url[0]}" == *.php ]]; then
        filedata=$(php $filename $cont)
elif [[ "${url[0]}" == *.py ]]; then
        filedata=$(python $filename $cont)
else
        filedata=$(<$filename)
fi
# Content-Length: ${#filedata}
        TRES="HTTP/1.1 200 OK
Cache-Control: private
Server: bash/2.1
Content-Type: $ctype
Connection: Close
Content-Length: ${#filedata}

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
