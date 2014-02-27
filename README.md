Bash web server using netcat
==========

Bash web server with the use of netcat. It supports file downloads, it servers static html, PHP, Python and binary files with arguments (GET). It checks for 404 errors and it keeps a server log.

Based on work by Paul Buchheit at: http://paulbuchheit.blogspot.ro/2007/04/webserver-in-bash.html
I fiddled a little with it and turned it into a decent web server, with server logs and all. (IP, query string,timestamp)
 
It supports file downloads, it servers static html, PHP, Python and binary files with arguments (GET). It checks for 404 errors and it keeps a server log.
It also servers php file without PHP installed on the server, using ph7 script interpreter.
 

What's new
=========
- added ph7 support, now you can run the server without php support and still be able to run most php files
(https://github.com/symisc/PH7)
- improved security, now it loggs IP and date into server.log file
- added default index.html directory index
- fixed serving jpg and other binary files with NUL in them

 
Fun facts
=========

faster then nginx at first run

5 times slower then nginx (after nginx caches the PHP code?)

executes binary faster then it can display static content

Performance: binary > sttic files > python > PHP


php files need to have the extension .php

python files need to have the extension .py

binaries need to have the extension .cb (C binary:) )


Usage
==========
chmod 755 server.sh

to run, type: ./server.sh

open a browser and go to http://YOUR.IP.ADDRESS/index.html


It's great if you just need a server for a short period of time and don't need security...
It only works on Linux. (I've tested it under Ubuntu)


I had great fun working on it. I hope you'll have as much fun with it as had.
 
If you find an use for it, drop me a line.
