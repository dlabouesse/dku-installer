#!/bin/bash

# Manage the following options
# -f : path to Dataiku installer (required)
# -l : path to license file (optional)
while getopts ":f:l:" option
do
    case $option in
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
echo $DKUINSTALLER

PORT_DESIGN="$(echo "$VERSION" | tr -d .)00"
PORT_AUTOMATION="$(echo "$VERSION" | tr -d .)10"
PORT_API="$(echo "$VERSION" | tr -d .)20"

if [ -z "$LICENSE" ]
then
    echo "Installing design node on port $PORT_DESIGN without license..."
    $DKUINSTALLER/installer.sh -d dss_home -p $PORT_DESIGN

    echo -e "\nInstalling automation node on port $PORT_AUTOMATION without license..."
    $DKUINSTALLER/installer.sh -t automation -d dss_home_automation -p $PORT_AUTOMATION

    echo -e "\nInstalling api node on port $PORT_API without license..."
    $DKUINSTALLER/installer.sh -t api -d dss_home_apinode -p $PORT_API
else
    echo -e "Installing design node on port $PORT_DESIGN with license..."
    $DKUINSTALLER/installer.sh -d dss_home -p $PORT_DESIGN -l ../$LICENSE
    
    echo -e "\nInstalling automation node on port $PORT_AUTOMATION with license..."
    $DKUINSTALLER/installer.sh -t automation -d dss_home_automation -p $PORT_AUTOMATION -l ../$LICENSE

    echo -e "\nInstalling api node on port $PORT_API with license..."
    $DKUINSTALLER/installer.sh -t api -d dss_home_apinode -p $PORT_API -l ../$LICENSE
fi

echo -e "\n################# Install completed! #################\n"
echo "Design node: http://localhost:$PORT_DESIGN (./$DKUDIR/dss_home/bin/dss start)"
echo "Automation node: http://localhost:$PORT_AUTOMATION (./$DKUDIR/dss_home_automation/bin/dss start)"
echo "API node: http://localhost:$PORT_API (./$DKUDIR/dss_home_apinode/bin/dss start)"

exit 0