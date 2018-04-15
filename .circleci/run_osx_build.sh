#!/usr/bin/env bash

set -x

echo "Removing homebrew from Circle CI to avoid conflicts."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall > ~/uninstall_homebrew
chmod +x ~/uninstall_homebrew
~/uninstall_homebrew -fq
rm ~/uninstall_homebrew

echo "Installing a fresh version of Miniconda."
MINICONDA_URL="https://repo.continuum.io/miniconda"
MINICONDA_FILE="Miniconda3-latest-MacOSX-x86_64.sh"
curl -L -O "${MINICONDA_URL}/${MINICONDA_FILE}"
bash $MINICONDA_FILE -b

echo "Downloading sdk"
curl -L -O https://github.com/phracker/MacOSX-SDKs/releases/download/10.13/MacOSX10.9.sdk.tar.xz
tar -xf MacOSX10.9.sdk.tar.xz -C $(xcode-select -p)/Platforms/MacOSX.platform/Developer/SDKs/
sed -i '' "s|<string>10.11</string>|<string>10.9</string>|g" $(xcode-select -p)/Platforms/MacOSX.platform/Info.plist

echo "Configuring conda."
source ~/miniconda3/bin/activate root
conda config --remove channels defaults
conda config --add channels defaults
conda config --add channels conda-forge
conda config --set show_channel_urls true
conda install --yes --quiet conda-forge-ci-setup=1
source run_conda_forge_build_setup


set -e
conda build ./recipe -m ./.ci_support/${CONFIG}.yaml

upload_or_check_non_existence ./recipe conda-forge --channel=main -m ./.ci_support/${CONFIG}.yaml

