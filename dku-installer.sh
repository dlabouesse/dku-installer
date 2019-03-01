#!/bin/bash

# Manage the following options
# -d : path to DATA_DIR to copy (optional)
# -f : path to Dataiku installer (required)
# -l : path to license file (optional)

while getopts ":f:l:d:" option
do
    case $option in
        d)
            DKUDATADIR=$OPTARG
            ;;
        f)
            DKUINSTALLER=$OPTARG
            ;;
        l)
            LICENSE=$OPTARG
            ;;
        :)
            echo "The option -$OPTARG requires an argument"
            exit 1
            ;;
        \?)
            echo "-$OPTARG : invalid option"
            exit 1
            ;;
    esac
done

if [ -z "$DKUINSTALLER" ]
then
    echo "Missing path to Dataiku installer (please use the -f option)"
    exit 1
fi

if [ -z "$LICENSE" ] && [ -z "$DKUDATADIR" ]
then
    echo -e "No Dataiku license nor DATA_DIR provided (-l or -d options).\nSince the API node requires a license, you'll have to manage that manually."
fi

VERSION=$(echo $DKUINSTALLER | cut -d'-' -f 3)
VERSION=${VERSION%".tar.gz"}

read -p "Do you confirm the installation of Dataiku $VERSION? (y/n)" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Install aborted"
    exit 0
fi
echo
echo "Installing Dataiku $VERSION..."
DKUDIR="DSS_$(echo $VERSION | tr . _)"
echo "Creating $DKUDIR folder..."
mkdir $DKUDIR
echo "Extracting $DKUINSTALLER..."
tar zxf $DKUINSTALLER -C ./$DKUDIR
cd $DKUDIR
DKUINSTALLER=$(ls)

PORT_DESIGN="$(echo "$VERSION" | tr -d .)00"
PORT_AUTOMATION="$(echo "$VERSION" | tr -d .)10"
PORT_API="$(echo "$VERSION" | tr -d .)20"

if [ -z "$LICENSE" ] && [ -z "$DKUDATADIR" ]
then
    echo "Installing design node on port $PORT_DESIGN without license..."
    $DKUINSTALLER/installer.sh -d dss_home -p $PORT_DESIGN

    echo -e "\nInstalling automation node on port $PORT_AUTOMATION without license..."
    $DKUINSTALLER/installer.sh -t automation -d dss_home_automation -p $PORT_AUTOMATION

    echo -e "\nInstalling api node on port $PORT_API without license..."
    $DKUINSTALLER/installer.sh -t api -d dss_home_apinode -p $PORT_API
elif [ -z "$LICENSE" ]
then
    echo "Migrating $DKUDATADIR..."
    cp -R ../$DKUDATADIR/dss_* . 
    echo "Generating new installid..."
    sed -i .backup "s/^installid[ ]=[ ]........................$/installid = $(date +%s | sha256sum | base64 | head -c 24 ; echo)/g" dss_home/install.ini
    echo "Updating ports..."
    sed -i "" "s/^port[ ]=[ ][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]]$/port = $PORT_DESIGN/g" dss_home/install.ini
    echo "Updating design node on migrated DATA_DIR..."    
    $DKUINSTALLER/installer.sh -d dss_home -u
    echo "Generating new installid..."
    sed -i .backup "s/^installid[ ]=[ ]........................$/installid = $(date +%s | sha256sum | base64 | head -c 24 ; echo)/g" dss_home_automation/install.ini
    echo "Updating ports..."
    sed -i "" "s/^port[ ]=[ ][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]]$/port = $PORT_AUTOMATION/g" dss_home_automation/install.ini
    echo "Updating automation node on migrated DATA_DIR..."    
    $DKUINSTALLER/installer.sh -t automation -d dss_home_automation -u
    echo "Generating new installid..."
    sed -i .backup "s/^installid[ ]=[ ]........................$/installid = $(date +%s | sha256sum | base64 | head -c 24 ; echo)/g" dss_home_apinode/install.ini
    echo "Updating ports..."
    sed -i "" "s/^port[ ]=[ ][[:digit:]][[:digit:]][[:digit:]][[:digit:]][[:digit:]]$/port = $PORT_API/g" dss_home_apinode/install.ini
    echo "Updating api node on migrated DATA_DIR..."    
    $DKUINSTALLER/installer.sh -t api -d dss_home_apinode -u
else
    echo -e "Installing design node on port $PORT_DESIGN with license..."
    $DKUINSTALLER/installer.sh -d dss_home -p $PORT_DESIGN -l ../$LICENSE
    
    echo -e "\nInstalling automation node on port $PORT_AUTOMATION with license..."
    $DKUINSTALLER/installer.sh -t automation -d dss_home_automation -p $PORT_AUTOMATION -l ../$LICENSE

    echo -e "\nInstalling api node on port $PORT_API with license..."
    $DKUINSTALLER/installer.sh -t api -d dss_home_apinode -p $PORT_API -l ../$LICENSE
fi

echo -e "\n################# Installation of Dataiku $VERSION completed! #################\n"
echo "You can now run ./dku-launcher.sh to start any of the installed nodes."
exit 0