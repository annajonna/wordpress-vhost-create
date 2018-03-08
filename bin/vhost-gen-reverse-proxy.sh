#!/bin/bash

if [ -h "$0" ]; then
    LENOGALL=${0##*/}    # Deletes longest match of */ from front of $0. Getting basename of symlink
    LEN=${LENOGALL%%_*}    # Deletes longest match of _* from back of $0. LEN is the part in front of _
    LENTYPA=${LENOGALL#*_}    # Deletes shortest match of *_ from front of $0. LENTYPA is the part after the first _
    LENLINK=true
else
    LEN=${1}.hi.is
    if [ "$1." = "." ]; then
        echo "Til dæmis að stofna lénið example-22.hi.is: "
        echo "Notkun: $0 example-22"
        exit 1
    fi
fi
echo "Lenid er: ${LEN}"
echo "Tegund Lens er: ${LENTYPA}"
SKRA="/etc/httpd/vhosts.d/${LEN}.http.redirect" 
SKRB="/etc/httpd/vhosts.d/${LEN}.https.redirect" 
case $LENTYPA in
httpproxy)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.http.incl_proxy" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.https.incl_proxy" 
  ;;
*)
  echo "Ok, sleppum þessu þá ."
  exit 0
  ;;
esac
if [ ! -e "${SKRA}" -o "$LENLINK" == "true" ]; then
    cp $TEMPLA  ${SKRA} 
    sed "s/template.hi.is/${LEN}/g" -i ${SKRA}  
else
    echo "Will not overwrite ${SKRA}"
fi     

if [ ! -e "${SKRB}" -o "$LENLINK" == "true" ]; then 
    cp $TEMPLB  ${SKRB}
    sed "s/template.hi.is/${LEN}/g" -i ${SKRB}  
else
    echo "Will not overwrite ${SKRB}"
fi


