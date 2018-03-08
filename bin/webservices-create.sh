#!/bin/bash

if [ "$1." = "." ];
then
    echo "Til dæmis að stofna vefsvæðið example með 1GB plássi (100MB er sjálfgefið ef engin stærð er gefin) : "
    echo "Notkun: $0 example 1G"
    exit 1
elif [ "$2." = "." ]
then
        KVOTI=100M
else
        KVOTI=$2
fi
VEFUR=$1
VILLUR=""
COMMENCE=0
VEFURUUID=""

# Sanity checks!!!
if PLASSVEFUR=$(lvs --noheadings /dev/webservices/$VEFUR -o lv_size 2>/dev/null)
then
    COMMENCE=false;
    VILLUR="Vefsvæðið er þegar til og hefur stærðina $PLASSVEFUR ."
fi

if [ -d "/export/webservices/$VEFUR" ] 
then
    COMMENCE=false
    VILLUR="${VILLUR}\nMappan fyrir vefsvæðið er þegar til."
fi

# if [ -d "$VEFMAPPA" ] && [ -x "$VEFMAPPA" ] &&  [ -w "$VEFMAPPA" ] && cd "$VEFMAPPA" && cd ../../../ ; then

if VEFURUUID=$(blkid /dev/webservices/$VEFUR -o export 2>/dev/null)
then
    COMMENCE=false
    VEFURUUIE=${VEFURUUID%%TYPE*}
#    VEFURUUID=$VEFURUUIE
    VEFURUUID=${VEFURUUIE#UUID\=}
    unset VEFURUUIE
    VILLUR="${VILLUR}\nUUID=$VEFURUUID ."
fi

#if [ -n "${VEFURUUID}" ] && VEFURFSTAB=$(cat /etc/fstab| grep ${VEFURUUID} ) || VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4")
#if VEFURFSTAB=$(cat /etc/fstab| grep ${VEFURUUID} ) || VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4")
#if /usr/bin/test -n "${VEFURUUID}" && VEFURFSTAB=$(cat /etc/fstab| grep ${VEFURUUID} ) || VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4")
#if [ -n "${VEFURUUID}" ] && VEFURFSTAB=$(cat /etc/fstab| grep ${VEFURUUID} ) || VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4")
#if [ -n "${VEFURUUID}" -a $(VEFURFSTAB=$(cat /etc/fstab| grep "${VEFURUUID}" )) -o $(VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4") ) ]
#if [[ VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4")  ]]
#if [[ ( -n "${VEFURUUID}" -a $(VEFURFSTAB=$(cat /etc/fstab| grep "${VEFURUUID}" )) ) -o $(VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4") ) ]]
#if [[ -n "${VEFURUUID}" -a cat /etc/fstab| grep "${VEFURUUID}"  -o cat /etc/fstab| grep "/export/webservices/$VEFUR ext4"  ]]
#if [[ -n "${VEFURUUID}" -a cat /etc/fstab| grep "${VEFURUUID}"  -o cat /etc/fstab| grep "/export/webservices/$VEFUR ext4"  ]]
#if [[ -n "${VEFURUUID}" && $(VEFURFSTAB=$(cat /etc/fstab| grep "${VEFURUUID}" ))  || $(VEFURFSTAB=$(cat /etc/fstab| grep "/export/webservices/$VEFUR ext4") ) ]]

if [ -n "${VEFURUUID}" ] ;
then
    if grep -q "${VEFURUUID}" /etc/fstab ;
    then
	VEFURFSTAB=$(cat /etc/fstab| grep ${VEFURUUID} );
	COMMENCE=false ;
	VILLUR="${VILLUR}\nSkráakerfistaflan inniheldur eftirfarandi:\n$VEFURFSTAB ." ;
    fi
elif grep -q "/webservices/$VEFUR ext4" /etc/fstab ;
then
    VEFURFSTAB=$(cat /etc/fstab| grep "/webservices/$VEFUR ext4");
    COMMENCE=false;
    VILLUR="${VILLUR}\nSkráakerfistaflan inniheldur eftirfarandi:\n$VEFURFSTAB ." ;
fi

if mount | grep -q "/webservices/$VEFUR type "  ;
then
    VEFURMOUNT=$(mount | grep "/webservices/$VEFUR type ");
    COMMENCE=false;
    VILLUR="${VILLUR}\nSkráakerfið er fest hér:\n$VEFURMOUNT ." ;
fi

if  exportfs -av | egrep -q -i "/webservices/$VEFUR$"  ;
then
    VEFUREXPORT=$(exportfs -av | egrep -i "/webservices/$VEFUR$" );
    COMMENCE=false;
    VILLUR="${VILLUR}\nSkráakerfið er útflutt hér:\n$VEFUREXPORT ." ;
fi


# Typical steps

#lvcreate -L 20G -n shogni-english webservices
#mkdir  /export/webservices/shogni-english
#mkfs.ext4 /dev/webservices/shogni-english
#blkid |tail -1 >> /etc/fstab
#vim /etc/fstab
#echo "  /export/webservices/shogni-english" >> /etc/fstab
#vim /etc/fstab
#mount /export/webservices/shogni-english 
#vim /etc/exports 
#exportfs -av |grep shogni
#cd /export/webservices/shogni-english

if [ $COMMENCE == false ] ;
then
    echo -e $VILLUR;
    exit 1;
else
#    exit 80;
    if lvcreate -L $KVOTI -n $VEFUR  webservices ;
    then
	if mkfs.ext4 /dev/webservices/$VEFUR ;
	then
	    VEFURUUID=$(blkid /dev/webservices/$VEFUR -o export 2>/dev/null)
	    VEFURUUIE=${VEFURUUID%%TYPE*}
	    VEFURUUID=${VEFURUUIE}
	    if mkdir -p  /export/webservices/$VEFUR ;
	    then
		VEFURFSTAB="$VEFURUUID /export/webservices/$VEFUR ext4 defaults 0 0"
		echo $VEFURFSTAB >> /etc/fstab 
		if mount /export/webservices/$VEFUR ;
		then
		    VEFUREXPORT="/export/webservices/$VEFUR @webservices(rw,sync,no_root_squash)"
		    echo $VEFUREXPORT >> /etc/exports
		    if exportfs -av |grep "/export/webservices/$VEFUR" ;
		    then
			echo -e "NFS drif tilbúið. Eftirfarandi þarf að setja í /etc/fstab á viðeigandi vefþjónum: \n";
			echo "stblade1.rhi.hi.is:/export/webservices/$VEFUR /info/$VEFUR nfs defaults,_netdev,nodiratime,noatime,rsize=16384,wsize=16384 0 0";
		    else
			echo -e "Aðgerðin mistókst. Nú þarf að þrífa eftir þessa aðgerð. \nNFS útflutningur misheppnaðist.";
		    fi
		else
		    echo -e "Aðgerðin mistókst. Nú þarf að þrífa eftir þessa aðgerð.\nFesting skráakerfisins miheppnaðist.";
		fi
	    else
		echo -e "Aðgerðin mistókst. Nú þarf að þrífa eftir þessa aðgerð.\nÞað miheppnaðist að búa til möppu fyrir skráakerfið.";
	    fi
	else
	    echo -e "Aðgerðin mistókst. Nú þarf að þrífa eftir þessa aðgerð.\nÞað miheppnaðist að búa til skrákerfið.";
	fi
    else
	echo -e "Aðgerðin mistókst. Nú þarf að þrífa eftir þessa aðgerð.\nÞað miheppnaðist að búa til lvm diskasneið.";
    fi
fi
