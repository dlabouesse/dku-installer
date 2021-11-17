#!/bin/bash

VERSIONS=()
for f in $((ls -d1 DSS_?_?_? ; ls -d1 DSS_??_?_?) 2> /dev/null); do
    VERSION=$(echo ${f#"DSS_"} | tr _ .)
    VERSIONS+=($VERSION)
done

if [[ ${#VERSIONS[*]} -eq 0 ]]
then
    echo -e "No installed version of Dataiku have been found.\nPlease start by installing one using ./dku-installer.sh"
    exit 1
fi
echo "The following versions of Dataiku DSS have been found:"
printf '%s\n' "${VERSIONS[@]}"
echo "Which version do you wan to run?"
read VERSION
DKUDIR="DSS_$(echo $VERSION | tr . _)"

while [ ! -d "$DKUDIR" ]
do
    echo -e "Dataiku $VERSION not found.\n\nWhich version do you want to run?"
    read VERSION
    DKUDIR="DSS_$(echo $VERSION | tr . _)"
done

cd $DKUDIR

NODES=()
for f in $(ls -d dss_home*); do
    case $f in
        dss_home)
            NODES+=("Design")
            ;;
        dss_home_automation)
            NODES+=("Automation")
            ;;
        dss_home_apinode)
            NODES+=("API")
            ;;
    esac
done

NODE=$((${#NODES[@]} + 1))
while [[ $NODE -gt ${#NODES[@]} ]]
do
echo -e "\nWhich node(s) do you want to start?"
    echo "0: All nodes"
    for i in "${!NODES[@]}"; do 
        printf "%s: %s node\n" "$(($i + 1))" "${NODES[$i]}"
    done
    read NODE
done

# Adapts the list of nodes to start depending of the user choice
if [[ ! $NODE -eq 0 ]]
then
    NODES=(${NODES[@]:$((NODE - 1)):1})
fi

# Starts nodes
for NODE in "${NODES[@]}"
do
    case $NODE in
        "Design")
            echo -e "\nStarting Design node..."
            ./dss_home/bin/dss start
            echo "#########################################"
            echo "Design node started."
            echo "The URL is: http://localhost:$(cat dss_home/install.ini | grep port | awk '{print $NF}')"
            echo "#########################################"
            ;;
        "Automation")
            echo -e "\nStarting Automation node..."
            ./dss_home_automation/bin/dss start
            echo "#########################################"
            echo "Automation node started."
            echo "The URL is: http://localhost:$(cat dss_home_automation/install.ini | grep port | awk '{print $NF}')"
            echo "#########################################"
            ;;
        "API")
            echo -e "\nStarting API node..."
            ./dss_home_apinode/bin/dss start
            echo "#########################################"
            echo "API node started."
            echo "The URL is: http://localhost:$(cat dss_home_apinode/install.ini | grep port | awk '{print $NF}')"
            echo "#########################################"
            ;;
    esac
done

echo
read -n 1 -s -r -p "Press any key to stop the nodes"
echo

# Stops nodes
for NODE in "${NODES[@]}"
do
    case $NODE in
        "Design")
            echo -e "\nStopping Design node..."
            ./dss_home/bin/dss stop
            ;;
        "Automation")
            echo -e "\nStopping Automation node..."
            ./dss_home_automation/bin/dss stop
            ;;
        "API")
            echo -e "\nStopping API node..."
            ./dss_home_apinode/bin/dss stop
            ;;
    esac
done

exit 0
