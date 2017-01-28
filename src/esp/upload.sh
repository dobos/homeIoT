curl -A "" -H "Accept:" -H "Expect:" -H "Content-Type:" \
     "http://$1/$2" --proxy 127.0.0.1:8888 --data-binary @$2 > /dev/null