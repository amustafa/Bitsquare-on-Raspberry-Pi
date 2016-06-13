#!/bin/bash
echo "#############################################################################################################"
echo "# Bitsquare Install Script for Raspberry PI.                                                                #"
echo "# https://github.com/amustafa                                                                               #"
echo "# Donations:                                                                                                #"
echo "#    BTC: 16zRJPnpXiGrNEN3L27nFfrqN239WGyKFb                                                                #"
echo "#    ETH: 0xf7256310bc2da3de5732C12213eeAdbB73E5C3BA                                                        #"
echo "#    XMR: 494MpncaE33Nzko9dCPe9h8KepPMf5srUdCMkfYJ3bnxdapCEmHyiy3WbwaVe4vUMveKAzAiA4j8xgUi29TpKXpm3xiwSnM   #"
echo "#############################################################################################################"
echo

SCRIPT_ROOT="$(dirname "$0")"
ARCHITECTURE=`uname -a`

if [ "$1" == "update" ]
  then

    echo "Updating Bitsquare"
    cd bitsquare
    git pull
    mvn clean package -DskipTests

else
echo "Bitsquare Installation Process"


echo 'deb http://mirrordirector.raspbian.org/raspbian/ stretch main contrib non-free rpi' | sudo tee -a /etc/apt/sources.list >/dev/null
sudo apt-get update
sudo apt-get install openjdk-8-jdk openjfx maven tor -y
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf

cd "$(dirname "$0")"
echo 'Enabling unlimited strength for cryptographic keys'
unzip jce_policy-8.zip
cd UnlimitedJCEPolicyJDK8/
sudo mv $JAVA_HOME/jre/lib/security/local_policy.jar $JAVA_HOME/jre/lib/security/local_policy_limited.jar
sudo mv $JAVA_HOME/jre/lib/security/US_export_policy.jar $JAVA_HOME/jre/lib/security/US_export_policy_limited.jar
sudo mv local_policy.jar $JAVA_HOME/jre/lib/security/
sudo mv US_export_policy.jar $JAVA_HOME/jre/lib/security/
cd "$(dirname "$0")"


echo "Setting Bouncy Castle Provider"
wget https://www.bouncycastle.org/download/bcprov-ext-jdk15on-154.jar
sudo mv bcprov-ext-jdk15on-154.jar $JAVA_HOME/jre/lib/ext/
echo 'security.provider.11=org.bouncycastle.jce.provider.BouncyCastleProvider' | sudo tee -a  $JAVA_HOME/jre/lib/security/java.security


echo "Installing bitcoinj"
cd ~
git clone -b FixBloomFilters https://github.com/bitsquare/bitcoinj.git
cd bitcoinj
mvn clean install -DskipTests -Dmaven.javadoc.skip=true

echo "Installing bitsquare"
cd ~
git clone https://github.com/bitsquare/bitsquare.git
cd bitsquare

echo "\tAdding tor cmd patch ..."
wget https://github.com/SjonHortensius/bitsquare/commit/338f7f117939ecc2fc302c3d57079f6c81c851a7.patch || :
patch -p1 <338f7f117939ecc2fc302c3d57079f6c81c851a7.patch || :

mvn clean package -DskipTests

# Instructions
echo "Before running, use 'sudo raspi-config'->'Advanced'->'Memory Split' to split the GPU memory 50/50."
echo "    the GPU needs more memory to run BitSquare!"

echo -e 'Run this script again to update from github. Run this command to start Bitsquare:\n\t/usr/bin/java -jar ~/src/bitsquare/gui/target/shaded.jar'
fi