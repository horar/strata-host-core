#
# Demo http server
#
# (c) 2019, Lubomir Carik
#


echo Starting server on 127.0.0.1:8000

python3 -m http.server 8000 --bind 127.0.0.1 --directory setup/pub
echo ...done
