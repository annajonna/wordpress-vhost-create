#!/bin/bash

if [ "$1." = "." ]
then
        echo "Til dæmis að stofna lénið example-22.hi.is: "
        echo "Notkun: $0 example-22"
        exit 1
fi
LEN=${1}.hi.is
FDRIVE=$(echo $LEN | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' | sed -r 's#(^([a-zA-Z0-9-]*)\..*$)|(.)#\2#g'  | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d')
SKRA="/etc/httpd/vhosts.d/${LEN}.conf" 

if [ ! -e "${SKRA}" ] ; then
    cp --no-clobber /etc/httpd/conf/template.hi.is.ipv4.https.conf ${SKRA} 
    sed "s/template/${FDRIVE}/g" -i ${SKRA}  
else
    echo "Will not overwrite ${SKRA}"
fi     

if [ ! -e "/etc/httpd/vhosts.d/${LEN}.redirect" ] ; then 
    cp --no-clobber /etc/httpd/conf/template.hi.is.ipv4.http.redirect /etc/httpd/vhosts.d/${LEN}.redirect 
    sed "s/template/${FDRIVE}/g" -i /etc/httpd/vhosts.d/${LEN}.redirect
else
    echo "Will not overwrite /etc/httpd/vhosts.d/${LEN}.redirect"
fi

#cp --no-clobber /etc/httpd/conf/template.hi.is.sslserveralias /etc/httpd/vhosts.d/${LEN}.sslserveralias
#cp --no-clobber /etc/httpd/conf/template.hi.is.serveralias /etc/httpd/vhosts.d/${LEN}.serveralias

VEFMAPPA=$(grep DocumentRoot $SKRA | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' | sed -r 's#(^[a-zA-Z]*[ \t]*(.*/htdocs$))#\2#g' | uniq )

pushd . >&/dev/null
if [ -d "$VEFMAPPA" ] && [ -x "$VEFMAPPA" ] &&  [ -w "$VEFMAPPA" ] && cd "$VEFMAPPA" && cd ../../../ ; then
    [[ "$PWD" != "/info/cms" ]] \
        && echo "Cowardly refusing to operate on $VEFMAPPA" && exit 1
    popd

    NOTANDI=$( stat -c %U $VEFMAPPA)
    VEFHOPUR=$(stat -c %G $VEFMAPPA)
    sed "s/suPHP_UserGroup.*$/suPHP_UserGroup $NOTANDI $VEFHOPUR/"     -i ${SKRA}

    mkdir -p ${VEFMAPPA}/../php_session
    echo ${NOTANDI}.${VEFHOPUR} $VEFMAPPA
    chown ${NOTANDI}.${VEFHOPUR} $VEFMAPPA/../{php_session,logs,php_tmp,.}
    chown -R ${NOTANDI}.${VEFHOPUR} $VEFMAPPA

    find ${VEFMAPPA} -type d -execdir /bin/chmod 2775  {} \+
    find ${VEFMAPPA} -type f -execdir /bin/chmod 0664  {} \+
else 
    echo "Alleged DocumentRoot is not acceptable: $VEFMAPPA"
    echo "Removing virtualhost file" && rm $SKRA

fi
