#!/bin/bash

if [ "$1." = "." ]; then
    echo "Til dæmis að stofna lénið example-22.hi.is: "
    echo "Notkun: $0 example-22"
    exit 1
fi
LEN=${1}.hi.is
echo "Lenid er: ${LEN}"
pushd .
cd /etc/httpd/vhosts.d/scripts/
VAL1="1: Venjulegt lén á http, HTTPS er alltaf vísað á HTTP. www er alltaf fjarlægt í vafra notandans."
VAL2="2: Venjulegt lén á http, HTTPS er alltaf vísað á HTTP. www er alltaf skeytt við lénið í vafra notandans."
VAL3="3: Venjulegt lén á http, HTTPS er alltaf vísað á HTTP. www er hvorki fjarlægt né bætt við."
VAL4="4: Öruggt lén á https (SSL), HTTP er alltaf vísað á HTTPS.  www er alltaf fjarlægt í vafra notandans."
VAL5="5: Lén sem svarar bæði HTTP og HTTPS og vefurinn sér um vísun á milli þeirra"
VAL6="6: Lén sem svarar bæði HTTP og HTTPS og vísar alltaf á annað lén"
VAL7="7: Lén sem svarar bæði HTTP og HTTPS og er með proxypass reverse á annað lén"
echo "$VAL1"
echo "$VAL2"
echo "$VAL3"
echo "$VAL4"
echo "$VAL5"
echo "$VAL6"
echo "$VAL7"
read -p "Veldu lénategund [1-7]:" -n 1 LENTYPA
echo ""
case $LENTYPA in
1)
  echo "$VAL1"
  rm -f ${LEN}_http*
#  ln --backup=off -s /usr/local/bin/vhost-gen-http-www-conf.sh ${LEN}
  ln --backup=off -s /usr/local/bin/vhost-gen.sh ${LEN}_http-www
  ;;
2)
  echo "$VAL2"
  rm -f ${LEN}_http*
#  ln --backup=off -s  /usr/local/bin/vhost-gen-httpwww-conf.sh ${LEN}
  ln --backup=off -s /usr/local/bin/vhost-gen.sh ${LEN}_httpwww
  ;;
3)
  echo "$VAL3"
  rm -f ${LEN}_http*
#  ln --backup=off -s /usr/local/bin/vhost-gen-http-conf.sh ${LEN}
  ln --backup=off -s /usr/local/bin/vhost-gen.sh ${LEN}_http
  ;;
4)
  echo "$VAL4"
  rm -f ${LEN}_http*
#  ln --backup=off -s /usr/local/bin/vhost-gen-https-conf.sh ${LEN}
  ln --backup=off -s /usr/local/bin/vhost-gen.sh ${LEN}_https
  ;;
5)
  echo "$VAL5"
  rm -f ${LEN}_http*
  ln --backup=off -s /usr/local/bin/vhost-gen.sh ${LEN}_https+http
  ;;
6)
  echo "$VAL6"
  echo "Vísun á annað lén. Til þess þarf að skrifa þann URI sem lénið skal vísa á." 
  read -p "URI :" LENREDIR
  echo ""
  rm -f ${LEN}_http*
  ln --backup=off -s /usr/local/bin/vhost-gen-redirect.sh ${LEN}_httpredirect
  if [ -n "$LENREDIR" ]; then
      echo "Redirect Permanent / $LENREDIR" > /etc/httpd/vhosts.d/redirect/${LEN}.redirect
      cat /etc/httpd/vhosts.d/redirect/${LEN}.redirect
  fi
  ;;
7)
  echo "$VAL7"
  echo "Vísun á annað lén. Til þess þarf að skrifa þann URI sem lénið skal vísa á." 
  read -p "URI :" LENREDIR
  echo ""
  rm -f ${LEN}_http*
  ln --backup=off -s /usr/local/bin/vhost-gen-proxy.sh ${LEN}_httpproxy
  if [ -n "$LENREDIR" ]; then
      echo "Redirect Permanent / $LENREDIR" > /etc/httpd/vhosts.d/proxy/${LEN}.httpproxy
      cat /etc/httpd/vhosts.d/proxy/${LEN}.httpproxy
  fi
  ;;
*)
  echo "Ok, sleppum þessu þá ."
  ;;
esac
popd

echo "Skoða Aliasa fyrir þetta lén. "
if [ -f "/etc/httpd/vhosts.d/alias/${LEN}.dirty-serveralias" -o -f "/etc/httpd/vhosts.d/alias/${LEN}.clean-serveralias" ]; then
    VAL5="Alias skrárnar eru þegar til. "
    SERVERALIAS=$( cat /etc/httpd/vhosts.d/alias/${LEN}.{dirty,clean}-serveralias | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' ) 
    if [ -n "$SERVERALIAS" ]; then
        VAL5=$( echo ${VAL5}; echo "Innihaldið er: ${SERVERALIAS}" )
        echo "$VAL5"
    else
        VAL5=$( echo ${VAL5}; echo "En þær innihalda ekkert." )
        echo "$VAL5"
        read -p "Á að fjarlægja þessar tómu skrár? [j]:" -n 1 DELALIAS
        if [ "$DELALIAS." == "j."  ]; then 
            rm -f /etc/httpd/vhosts.d/alias/${LEN}.{dirty,clean}-serveralias
        else 
            echo "Skrárnar voru ekki fjarlægðar."
        fi

    fi
else
    VAL5="Alias skrárnar eru EKKI til. "
    echo "$VAL5"
    read -p "Á að búa skrárnar til? [j]:" -n 1 MAKALIAS
    if [ "$MAKALIAS." == "j."  ]; then 
        cp --no-clobber /etc/httpd/conf/template.hi.is.dirty-serveralias /etc/httpd/vhosts.d/alias/${LEN}.dirty-serveralias
        cp --no-clobber /etc/httpd/conf/template.hi.is.clean-serveralias /etc/httpd/vhosts.d/alias/${LEN}.clean-serveralias
        echo ""
        echo "Nú geturðu sett inn tvær tegundir af alíösum, hreina alíasa sem eru jafngild heiti vefsins, og svo óhreina aliasa, þeir eru ekki jafngildir léninu heldur vísa þeir á lénið með þvi að endurskrifa (rewrite) yfir á raunverulegt heiti lénsins. "
        read -p "Hreinir alíasar :"  CLEANALIAS
        read -p "Skítugir alíasar:"  DIRTYALIAS
        if [ -n "$CLEANALIAS" ]; then 
            echo "ServerAlias ${CLEANALIAS}" >> /etc/httpd/vhosts.d/alias/${LEN}.clean-serveralias
        fi
        if [ -n "$DIRTYALIAS" ]; then
            echo "ServerAlias ${DIRTYALIAS}" >> /etc/httpd/vhosts.d/alias/${LEN}.dirty-serveralias
        fi
    else 
        echo "Alias skrárnar voru ekki gerðar."
    fi

fi


