# https://gist.github.com/billpatrianakos/cb72e984d4730043fe79cbe5fc8f7941 

echo "Setting up service..."
sudo cp lights /etc/init.d/
sudo chmod +x /etc/init.d/lights
sudo update-rc.d lights defaults

echo "Installing lirc..."
sudo su -c "grep '^deb ' /etc/apt/sources.list | sed 's/^deb/deb-src/g' > /etc/apt/sources.list.d/deb-src.list"
sudo apt update
sudo apt install -y vim devscripts dh-exec doxygen expect libasound2-dev libftdi1-dev libsystemd-dev libudev-dev libusb-1.0-0-dev libusb-dev man2html-base portaudio19-dev socat xsltproc python3-yaml dh-python libx11-dev python3-dev python3-setuptools

mkdir ~/lirc-src
cd ~/lirc-src
apt source lirc

wget https://raw.githubusercontent.com/neuralassembly/raspi/master/lirc-gpio-ir-0.10.patch
patch -p0 -i lirc-gpio-ir-0.10.patch
cd lirc-0.10.1
debuild -uc -us -b

cd ~/lirc-src
sudo apt install ./liblirc0_0.10.1-5.2_armhf.deb ./liblircclient0_0.10.1-5.2_armhf.deb ./lirc_0.10.1-5.2_armhf.deb

cd /opt/lights/
sudo cp lirc_options.conf /etc/lirc/lirc_options.conf
sudo cp lircd.conf /etc/lirc/lircd.conf

cd ~/lirc-src
sudo apt install -y --allow-downgrades ./liblirc0_0.10.1-5.2_armhf.deb ./liblircclient0_0.10.1-5.2_armhf.deb ./lirc_0.10.1-5.2_armhf.deb

export PKG_CONFIG_PATH=~/lirc-src/lirc-0.10.1/
cd ~/lirc-src/lirc-0.10.1/python-pkg
sudo python3 setup.py install
cd /opt/lights/


echo "Installing git..."
sudo apt-get install git

echo "Installing pip..."
sudo apt-get install python3-pip

echo "Installing gpioero..."
sudo apt install python3-gpiozero

echo "Installing RPI.GPIO 0.6.3..."
sudo apt-get remove RPi.GPIO
sudo pip3 install RPi.GPIO==0.6.3

echo "Setting up /boot/config.txt..."
# sudo sed -i -e 's/#dtoverlay=vc4-fkms-v3d/dtoverlay=dwc2,gpio-ir,gpio_pin=24/g' /boot/config.txt
sudo cp config.txt /boot/config.txt

echo "Done. Please reboot now."
