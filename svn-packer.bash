#!/bin/bash
#script written by anzipex

SOURCE_LIST=(svn local)
PACKER_PATH=$HOME/svn_packer
LOCAL_REVISION=`svn info $1 | grep '^Revision:' | sed -e 's/^Revision: //'`
LOCAL_PATH=`svn info $1 | grep '^Path:' | sed -e 's/^Path: //'`
LOCAL_DIR=`svn info $1 | grep '^Path:' | sed -e 's/^Path: //' | sed 's:.*/::'`
URL=`svn info $1 | grep '^URL:' | sed -e 's/^URL: //'`
REVISION=`svn info $1 | grep '^Revision:' | sed -e 's/^Revision: //'`

print_sources() {
    echo "Choose source for packing: "
    echo "0)" ${SOURCE_LIST[0]}
    echo "1)" ${SOURCE_LIST[1]}
    echo -n "#? "
}

print_revision() {
    echo "Revision: $REVISION"
}

print_archive_creating() {
    echo -e "Archive is creating..."
}

print_done() {
    echo -e "Done"
}

print_packed_path() {
    echo "$PACKER_PATH/$LOCAL_DIR.tar.gz"
}

recreate_archive() {
    cd $PACKER_PATH
    tar czf $LOCAL_DIR.tar.gz $LOCAL_DIR
    rm -R $PACKER_PATH/$LOCAL_DIR
}

checkout() {
    n=$(svn info -R $URL | grep "URL: " | uniq | wc -l)
    i=1
    while read line filename
    do
        counter=$(((100*(++i)*2)/n))
        echo -ne ">Downloading $counter%\r"
        echo -ne '\r'
    done < <(svn co $URL -r $LOCAL_REVISION $PACKER_PATH/$LOCAL_DIR)
    echo -ne "Downloaded 100%  \r"
    echo -ne '\r'
    echo ""
}

svn_packer() {
    print_revision
    checkout
    rm -R $PACKER_PATH/$LOCAL_DIR/.svn
    print_archive_creating
    recreate_archive
    print_done
    print_packed_path
}

local_packer() {
    print_revision
    print_archive_creating
    cp -R $LOCAL_PATH $PACKER_PATH
    rm -R $PACKER_PATH/$LOCAL_DIR/.svn
    recreate_archive
    print_done
    print_packed_path
}

create_packer_path() {
    if [ -d "$PACKER_PATH" ];
    then
        rm -Rf $PACKER_PATH;
    fi
    mkdir -p $PACKER_PATH/$LOCAL_DIR
}

identify_source() {
    if [ $SOURCE -eq "0" ];
    then
        svn_packer
    elif [ $SOURCE -eq "1" ];
    then
        local_packer
    fi
}

source_action() {
    if [ "$SOURCE" -le "-1" ] || [ "$SOURCE" -ge "2" ];
    then
        echo "Invalid input" && echo ""
        print_sources
        read SOURCE
        source_action
    else
        echo "Source for packing: ${SOURCE_LIST[$SOURCE]}"
        create_packer_path
        identify_source
    fi
}

set_source() {
    until [ ! -z $SOURCE ]
    do
        print_sources
        read SOURCE
        if [ ! -z $SOURCE ];
        then
            source_action
        else
            echo "Invalid input" && echo ""
        fi
    done
}

set_source

exit 0
