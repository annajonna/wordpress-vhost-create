#!/bin/bash

if [ -h "$0" ]; then
    LENOGALL=${0##*/}    # Deletes longest match of */ from front of $0. Getting basename of symlink
    LEN=${LENOGALL%%_*}    # Deletes longest match of _* from back of $0. LEN is the part in front of _
    LENTYPA=${LENOGALL#*_}    # Deletes shortest match of *_ from front of $0. LENTYPE is the part after the first _
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
#exit 0
FDRIVE=$(echo $LEN | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' | sed -r 's#(^([a-zA-Z0-9-]*)\..*$)|(.)#\2#g'  | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d')
SKRA="/etc/httpd/vhosts.d/${LEN}.http.conf" 
SKRB="/etc/httpd/vhosts.d/${LEN}.https.conf" 
# template.hi.is.ipv4.http-www.conf  
# template.hi.is.ipv4.httpwww.conf
# template.hi.is.ipv4.http.conf  
# template.hi.is.ipv4.https.conf  
# template.hi.is.ipv4.http.redirect  
# template.hi.is.ipv4.https.redirect  
case $LENTYPA in
http-www)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.http-www.conf" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.https.redirect" 
  ;;
httpwww)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.httpwww.conf" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.https.redirect" 
  ;;
http)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.http.conf" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.https.redirect" 
  ;;
https)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.https.conf" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.http.redirect" 
  SKRA="/etc/httpd/vhosts.d/${LEN}.https.conf" 
  SKRB="/etc/httpd/vhosts.d/${LEN}.http.conf" 
  ;;
https+http)
  TEMPLA="/etc/httpd/conf/template.hi.is.ipv4.http-www.conf" 
  TEMPLB="/etc/httpd/conf/template.hi.is.ipv4.https.conf" 
  ;;
*)
  echo "Ok, sleppum þessu þá ."
  exit 0
  ;;
esac

if [ ! -e "${SKRA}" -o "$LENLINK" == "true" ]; then
    cp $TEMPLA  ${SKRA} 
    sed "s/template/${FDRIVE}/g" -i ${SKRA}  
else
    echo "Will not overwrite ${SKRA}"
fi     

if [ ! -e "${SKRB}" -o "$LENLINK" == "true" ]; then 
    cp $TEMPLB  ${SKRB}
    sed "s/template/${FDRIVE}/g" -i  ${SKRB}
else
    echo "Will not overwrite ${SKRB}"
fi

VEFMAPPA=$(grep DocumentRoot $SKRA | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' | sed -r 's#(^[a-zA-Z]*[ \t]*(.*/htdocs$))#\2#g' | uniq )

pushd . >&/dev/null
if [ -d "$VEFMAPPA" ] && [ -x "$VEFMAPPA" ] &&  [ -w "$VEFMAPPA" ] && cd "$VEFMAPPA" && cd ../../../ ; then
    [[ "$PWD" != "/info" ]] \
        && echo "Cowardly refusing to operate on $VEFMAPPA" && exit 1
    popd

    NOTANDI=$( stat -c %U $VEFMAPPA)
    VEFHOPUR=$(stat -c %G $VEFMAPPA)
    sed "s/suPHP_UserGroup.*$/suPHP_UserGroup $NOTANDI $VEFHOPUR/"     -i ${SKRA}
    sed "s/suPHP_UserGroup.*$/suPHP_UserGroup $NOTANDI $VEFHOPUR/"     -i ${SKRB}

    mkdir -p ${VEFMAPPA}/../{php_session,logs,php_tmp}
    echo ${NOTANDI}.${VEFHOPUR} $VEFMAPPA
    chown ${NOTANDI}.${VEFHOPUR} $VEFMAPPA/../{php_session,logs,php_tmp,.}
    chown -R ${NOTANDI}.${VEFHOPUR} $VEFMAPPA

    find ${VEFMAPPA} -type d -execdir /bin/chmod 2775  {} \+
    find ${VEFMAPPA} -type f -execdir /bin/chmod 0664  {} \+
else 
    echo "Alleged DocumentRoot is not acceptable: $VEFMAPPA"
    echo "Removing virtualhost file" && rm $SKRA $SKRB

fi
