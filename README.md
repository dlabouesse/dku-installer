# Introduction
The purpose of this script is to automatically install the following nodes of Dataiku in one single command:
- Design node
- Automation node
- API node

# How to use?
This script accepts two input options:
- **Dataiku installer**

The path to the Dataiku installer in the `.tar.gz` format must be set using the `-f` option.

`./dku-installer.sh -f dataiku-dss-5.0.5-osx.tar.gz`

- **License file (optional)**

The path to the licence file can be set using the `-l` option.

`./dku-installer.sh -f dataiku-dss-5.0.5-osx.tar.gz -l license.json`

# Running details
## Directories
This script creates a folder depending of the version of Dataiku you want to install, that will respects the following schema `DSS_$VERSION` (e.g `DSS_5_0_3`).
Then, it will extract the installer in this folder, and install the 3 nodes using the following `DATA_DIR` directories:
- Design node: `/DSS_$VERSION/dss_home`
- Automation node: `/DSS_$VERSION/dss_home_automation`
- API node: `/DSS_$VERSION/dss_home_apinode`

## Ports
Each node is installed on a port depending of the version of DSS and which is suffixed by the following number depending of the node:
- Design node: `00` (e.g `50300`)
- Automation node: `10` (e.g `50310`)
- API node: `20` (e.g `50320`)