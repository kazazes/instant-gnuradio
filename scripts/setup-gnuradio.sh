#!/bin/bash

set -eux

export LANG=en_US.UTF-8
export PATH="$HOME/.local/bin:${PATH}"

echo "gnuradio - rtprio 99" | sudo tee -a /etc/security/limits.conf
sudo mv 90-usrp.conf /etc/sysctl.d/

### PYBOMBS
sudo apt -y install python-ipython python-scipy python-numpy python-qwt5-qt4 python-wxgtk3.0 multimon sox

sudo apt-get -y install python-pip

# broken pybombs
pip install --user git+git://github.com/gnuradio/pybombs.git

pybombs -v recipes add gr-recipes git+https://github.com/gnuradio/gr-recipes.git
pybombs -v recipes add gr-etcetera git+https://github.com/gnuradio/gr-etcetera.git

mkdir -p /home/gnuradio/pybombs
pybombs prefix init /home/gnuradio/pybombs -a master
pybombs config default_prefix master
pybombs config makewidth $(nproc)

echo 'PATH="$HOME/.local/bin:${PATH}"' >> .zshrc
echo 'PATH="$HOME/.local/bin:${PATH}"' >> .bashrc
echo "source /home/gnuradio/pybombs/setup_env.sh" >> .zshrc
echo "source /home/gnuradio/pybombs/setup_env.sh" >> .bashrc

### RTL-SDR
pybombs -v install rtl-sdr
sudo cp pybombs/src/rtl-sdr/rtl-sdr.rules /etc/udev/rules.d/

### HACKRF
sudo apt-get -y install pkg-config libfftw3-dev
pybombs -v install hackrf
sudo cp pybombs/src/hackrf/host/libhackrf/53-hackrf.rules /etc/udev/rules.d/

### BLADERF
pybombs -v install bladeRF
sed 's/@BLADERF_GROUP@/plugdev/g' pybombs/src/bladeRF/host/misc/udev/88-nuand.rules.in > pybombs/src/bladeRF/host/misc/udev/88-nuand.rules
sudo cp pybombs/src/bladeRF/host/misc/udev/88-nuand.rules /etc/udev/rules.d/

### UHD
pybombs -v install uhd
sudo cp pybombs/src/uhd/host/utils/uhd-usrp.rules /etc/udev/rules.d/
pybombs/lib/uhd/utils/uhd_images_downloader.py

### GNU RADIO
pybombs config --package gnuradio gitbranch maint
pybombs -v install gnuradio
/home/gnuradio/pybombs/libexec/gnuradio/grc_setup_freedesktop install
rm -rf ~/.gnome/apps/gnuradio-grc.desktop
rm -rf ~/.local/share/applications/gnuradio-grc.desktop
mv gnuradio-grc.desktop .local/share/applications/gnuradio-grc.desktop

### SoapySDR
pybombs -v install soapysdr soapyremote soapybladerf

### GR OSMOSDR
pybombs -v install gr-osmosdr

### GQRX
pybombs -v install gqrx
xdg-icon-resource install --context apps --novendor --size 96 Pictures/gqrx-icon.png

### FOSPHOR
sudo apt-get -y install libfreetype6-dev ocl-icd-opencl-dev python-opengl lsb-core
pybombs -v install gr-fosphor
xdg-icon-resource install --context apps --novendor --size 96 Pictures/fosphor-icon.png

cd Downloads
tar xvf opencl_runtime_16.1.2_x64_rh_6.4.0.37.tgz
sudo opencl_runtime_16.1.2_x64_rh_6.4.0.37/install.sh -s opencl-silent.cfg
cd ~/pybombs/src/gr-fosphor/build
set +u
source /home/gnuradio/pybombs/setup_env.sh
set -u
cmake -DOpenCL_LIBRARY=/opt/intel/opencl-1.2-6.4.0.37/lib64/libOpenCL.so ..
make
make install
cd

pybombs -v install inspectrum
xdg-icon-resource install --context apps --novendor --size 96 Pictures/inspectrum-icon.png

### CLEAN UP OUR STUFF
rm -r Downloads/*

### FAVORITE APPLICATIONS
xvfb-run dconf write /org/gnome/shell/favorite-apps "['gnuradio-grc.desktop', 'gqrx.desktop', 'fosphor.desktop', 'inspectrum.desktop', 'terminator.desktop', 'gnuradio-web.desktop', 'firefox.desktop', 'org.gnome.Nautilus.desktop']"

### The German Code
# xvfb-run dconf write /org/gnome/desktop/input-sources/sources "[('xkb', 'de')]"
