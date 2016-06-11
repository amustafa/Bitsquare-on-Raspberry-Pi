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

echo 'Installing compatible version of java ...'
tar zxf jdk-8u91-linux-arm32-vfp-hflt.tar.gz
sudo mv jdk1.8.0_91/ /opt/
sudo chown root:root -R /opt/jdk1.8.0_91
sudo ln -s /opt/jdk1.8.0_91 /opt/jdk8

echo 'Setting Java ...'
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk8/bin/javac 1
sudo update-alternatives --install /usr/bin/java java /opt/jdk8/bin/java 1
echo 1 | sudo update-alternatives --config javac
echo 1 | sudo update-alternatives --config java
echo "JDK_HOME=/opt/jdk8" | sudo tee -a /etc/profile
echo "JAVA_HOME=/opt/jdk8" | sudo tee -a /etc/profile
JDK_HOME=/opt/jdk8
JAVA_HOME=/opt/jdk8
cd "$(dirname "$0")"


echo "Installing JavaFX"
# JavaFX was removed from arm version of SDK. Need to add it back in.
# http://gluonhq.com/labs/javafxports/downloads/
unzip -qq armv6hf-sdk.zip
cd armv6hf-sdk
sudo cp rt/lib/ext/jfxrt.jar /opt/jdk8/jre/lib/ext/
sudo cp rt/lib/arm/* /opt/jdk8/jre/lib/arm/
sudo cp rt/lib/javafx.platform.properties /opt/jdk8/jre/lib/
sudo cp rt/lib/javafx.properties /opt/jdk8/jre/lib/
sudo cp rt/lib/jfxswt.jar /opt/jdk8/jre/lib/
cd "$(dirname "$0")"

echo 'Enabling unlimited strength for cryptographic keys'
unzip jce_policy-8.zip
cd UnlimitedJCEPolicyJDK8/
sudo mv /opt/jdk8/jre/lib/security/local_policy.jar /opt/jdk8/jre/lib/security/local_policy_limited.jar
sudo mv /opt/jdk8/jre/lib/security/US_export_policy.jar /opt/jdk8/jre/lib/security/US_export_policy_limited.jar
sudo mv local_policy.jar /opt/jdk8/jre/lib/security/
sudo mv US_export_policy.jar /opt/jdk8/jre/lib/security/
cd "$(dirname "$0")"

echo "Setting Bouncy Castle Provider"
wget https://www.bouncycastle.org/download/bcprov-ext-jdk15on-154.jar
sudo mv bcprov-ext-jdk15on-154.jar /opt/jdk8/jre/lib/ext/
echo 'security.provider.11=org.bouncycastle.jce.provider.BouncyCastleProvider' | sudo tee -a  /opt/jdk8/jre/lib/security/java.security

echo 'Installing prequisite packages from apt'
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install maven -y

echo "Installing bitcoinj"
cd ~
git clone -b FixBloomFilters https://github.com/bitsquare/bitcoinj.git
cd bitcoinj
mvn clean install -DskipTests -Dmaven.javadoc.skip=true

echo "Installing bitsquare"
cd ~
git clone https://github.com/bitsquare/bitsquare.git
cd bitsquare
mvn clean package -DskipTests

# Instructions
echo
echo "To Run: java -jar ~/bitsquare/gui/target/shaded.jar"
