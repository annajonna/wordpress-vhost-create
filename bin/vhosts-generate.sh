#!/bin/bash

#NameVirtualHost 130.208.165.74:80

# Fetching Include file pattern
APACHEVH=$(grep Include /etc/httpd/conf/httpd.conf | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' |grep auto | sed -r 's#(^[a-zA-Z]*[ \t]*(.*$))#\2#g'); 
# Fetching NAmeVirtualHost ip numbers or hostnames excluding port
APACHENVHOST=$(grep NameVirtualHost /etc/httpd/conf/httpd.conf | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d;/:80$/d;/:443$/d' | sed -r 's#(^[a-zA-Z]*[ \t]*(.*):[0-9]+)#\2#g' | uniq ); 

#echo APACHEVH: $APACHEVH
cd /  # preventing file expansion from APACHEVH in for loop
for APACHEINCL in $APACHEVH; do
#    echo APACHEINCL: $APACHEINCL
    APACHEINCLD=$(echo "$APACHEINCL" | sed -r 's#(((.*))\*\..*$)#\3#g' )
#    echo APACHEINCLD: $APACHEINCLD
    APACHEFILE="$(echo "$APACHEINCL" | sed -r 's#(^.*/(\*\..*$))#\2#g;s#^#\.\/#' )"
#    echo APACHEFILE: "$APACHEFILE"
    cd /etc/httpd
    if [ -d "$APACHEINCLD" ] && [ -x "$APACHEINCLD" ] &&  [ -w "$APACHEINCLD" ] && cd "$APACHEINCLD" ; then
#        pwd
        [[ "$PWD" == "/etc/httpd/vhosts.d" ]] || [[ "$PWD" == "/etc/httpd/conf" ]] ||  [[ "$PWD" == "/etc/httpd" ]]  \
            && echo "Cowardly refusing to operate on $PWD" && exit 1
        rm -f $APACHEFILE; 
        cp -p /etc/httpd/vhosts.d/$APACHEFILE .
        for SKRA in $APACHEFILE; do
            if [ -e $SKRA ]; then 
#                echo SKRA: $SKRA
# The policy is to add 8000 to all port numbers on cluster backends
                sed '/VirtualHost/s/:80>/:8080>/' -i $SKRA; 
                sed '/VirtualHost/s/:81>/:8081>/' -i $SKRA; 
                sed '/VirtualHost/s/:443>/:8443>/' -i $SKRA; 
                sed '/VirtualHost/s/:444>/:8444>/' -i $SKRA; 
                sed '/VirtualHost/s/:445>/:8445>/' -i $SKRA; 
                sed '/VirtualHost/s/:446>/:8446>/' -i $SKRA; 
# Substitute the ip number in the file SKRA with the ip number in NameVirtualHost                
                sed -r "/VirtualHost/s/[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/$APACHENVHOST/" -i $SKRA; 
            fi
        done    
    else
        echo "Cowardly refusing to change directory to $APACHEINCLD" && exit 1 
    fi 
    cd /
done 
