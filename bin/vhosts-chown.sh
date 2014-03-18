#!/bin/bash

if [ "$1." = "." ]
then
        echo "Notkun: $0 ./foo/virtualhost.conf"
        exit 1
fi
SKRA=$1
VEFMAPPA=$(grep DocumentRoot $SKRA | sed 's/^[ \t]*//;s/[ \t]*$//;/^$/d;/^#/d' | sed -r 's#(^[a-zA-Z]*[ \t]*(.*/htdocs$))#\2#g' | uniq )

#VEFMAPPA=$1

pushd .
if [ -d "$VEFMAPPA" ] && [ -x "$VEFMAPPA" ] &&  [ -w "$VEFMAPPA" ] && cd "$VEFMAPPA" && cd ../../../ ; then
    [[ "$PWD" != "/info/cms" ]] \
        && echo "Cowardly refusing to operate on $VEFMAPPA" && exit 1
    popd

    NOTANDI=$( stat -c %U $VEFMAPPA)
    VEFHOPUR=$(stat -c %G $VEFMAPPA)
    sed "s/suPHP_UserGroup.*$/suPHP_UserGroup $NOTANDI $VEFHOPUR/"     -i ${SKRA}

    echo ${NOTANDI}.${VEFHOPUR} $VEFMAPPA
    chown -R ${NOTANDI}.${VEFHOPUR} $VEFMAPPA

    find ${VEFMAPPA} -type d -execdir /bin/chmod 2775  {} \+
    find ${VEFMAPPA} -type f -execdir /bin/chmod 0664  {} \+

fi
