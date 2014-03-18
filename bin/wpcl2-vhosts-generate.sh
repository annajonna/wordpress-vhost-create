#!/bin/bash
rm -f /etc/httpd/vhosts.d/cl2/auto/*.{conf,redirect}
cp -f /etc/httpd/vhosts.d/*.{conf,redirect} /etc/httpd/vhosts.d/cl2/auto/
cd /etc/httpd/vhosts.d/cl2/auto/
for SKRA in *.{conf,redirect}; do 
    sed '/VirtualHost 130.208.165/s/73:443/75:8443/' -i $SKRA; 
    sed '/VirtualHost 130.208.165/s/73:80/75:8080/' -i $SKRA; 
    done

