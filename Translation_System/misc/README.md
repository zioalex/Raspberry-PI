- [Intro](#intro)
  - [Consideration](#consideration)
  - [Goals](#goals)
  - [Architecture](#architecture)
- [Requirements](#requirements)
- [Setup](#setup)
  - [How to prepare the SD card with Ubuntu 22.04](#how-to-prepare-the-sd-card-with-ubuntu-2204)
  - [Boot Ubuntu](#boot-ubuntu)
  - [Important notes](#important-notes)
  - [Hardware setup](#hardware-setup)
    - [LCD Display 4.3inch\_DSI\_LCD](#lcd-display-43inch_dsi_lcd)
    - [Cooling solution](#cooling-solution)
    - [Attach the FAN](#attach-the-fan)
  - [Installation](#installation)
    - [Enable every user to start](#enable-every-user-to-start)
    - [Chrome installation without snap](#chrome-installation-without-snap)
    - [Install Jitsi](#install-jitsi)
    - [Audio Setup - To be confirmed](#audio-setup---to-be-confirmed)
  - [Chromium installation - To be confirmed](#chromium-installation---to-be-confirmed)
  - [Jitsi setup](#jitsi-setup)
    - [Jitsi customization](#jitsi-customization)
    - [Recompile jniwrapper-native-1.0-SNAPSHOT](#recompile-jniwrapper-native-10-snapshot)
  - [SSL Certificate](#ssl-certificate)
    - [SSL Certificate creation](#ssl-certificate-creation)
    - [Nginx SSL Certificate configuration](#nginx-ssl-certificate-configuration)
    - [Jitsi SSL Certificate configuration](#jitsi-ssl-certificate-configuration)
  - [Enable the NGINX config](#enable-the-nginx-config)
  - [Prosody setup](#prosody-setup)
  - [Audio Recording](#audio-recording)
    - [Asound conf - Is this used in the last pulse version?](#asound-conf---is-this-used-in-the-last-pulse-version)
    - [Create the output sink called recording](#create-the-output-sink-called-recording)
    - [Attach the Mic to the sink](#attach-the-mic-to-the-sink)
    - [Test the recording with PulseAudio](#test-the-recording-with-pulseaudio)
    - [Audio Recording References](#audio-recording-references)
    - [Jupyter setup to record the audio with Python](#jupyter-setup-to-record-the-audio-with-python)
  - [Network setup](#network-setup)
  - [Backend setup](#backend-setup)
    - [Node Js](#node-js)
  - [Frontend setup](#frontend-setup)
  - [GUI](#gui)
    - [GUI Tuning](#gui-tuning)
    - [VNC Setup](#vnc-setup)
      - [VNC config](#vnc-config)
- [Challenge](#challenge)
- [Best practices](#best-practices)
- [Disable the screen dimming -  RO CONFIG](#disable-the-screen-dimming----ro-config)
- [RO FS](#ro-fs)
  - [References](#references)
- [Monitor the temperature](#monitor-the-temperature)
- [Disable not useful services](#disable-not-useful-services)
  - [Auto update](#auto-update)
  - [Snap](#snap)
  - [Remove snapd completely](#remove-snapd-completely)
  - [Cleanup Snap](#cleanup-snap)
- [Removes old revisions of snaps](#removes-old-revisions-of-snaps)
- [Backup](#backup)
- [Todo](#todo)
- [References](#references-1)

# Intro

This is the next version of the Translation System. With the legacy system based on Icecast and Darkice we got good the results in terms of easiness of implementation and usabiity but the latency (1-3 secs) is not anymore acceptable.

We are now aiming to have short latency between the original voice and the translation.

The goal is to have a translator hearing the original audio and all the other listening it without any video/comments/or other interruptions allowed.

The software choosen is Jitsi were we have very short delays.

## Consideration

Running Jitsi on a Raspberry PI can looks trivial, and installing the software it is but the goal is to make the translator independent by any other device and have the meeting in control.
The translator is not a technical person and therefore the interaction with the Raspberry PI must be as easy as possible like as well the user part.

Jitsi has per se some hard requirements to work properly

## Goals

- close to zero delay
- the system can works also in a not internet connected network
- the traffic is every case not leaving the LAN
- the translator is autonomous in starting the meeting
- he can control the meeting
  - rejoin
  - restart
  - mute all
  - check the partipants counts
  - poweroff
- *the translated audio can be recorded - optional*

## Architecture
![Architecture](./img/architecture.drawio.png)

The choosen OS is Ubuntu for Raspberry PI 4. The reason is that the Raspberry PI OS is not supporting the latest version of Jitsi and the Ubuntu is the only one that is supporting it.

# Requirements
- Raspberry PI 4 (2GB) or higher - With the 4GB version you would need less tuning for Jitsi
- An USB microphone adapter - Write the model here
- Microphone
- A valid SSL certificate
# Setup

## How to prepare the SD card with Ubuntu 22.04
Download the Ubuntu 22.04 Server image from [Ubuntu](https://ubuntu.com/download/raspberry-pi/thank-you?version=22.04.2&architecture=server-arm64+raspi).
Identify the disk with the SD card using lsblk or df to see the mounted device. Be sure to umount before flash it.

Flash it on the SD card with the following commands:
    SD_DEVICE="PUT YOUR VALUE HERE" # I.E: /dev/sde

    xz -d ubuntu-22.04.2-preinstalled-server-arm64+raspi.img.xz
    sudo dd bs=4M if=./ubuntu-22.04.2-preinstalled-server-arm64+raspi.img of=$SD_DEVICE conv=fdatasync status=progress

Or use the Raspberry PI Imager[*]

    sudo apt install rpi-imager
    rpi-imager

[*]: https://discourse.ubuntu.com/t/how-to-install-ubuntu-server-on-your-raspberry-pi/14660

## Boot Ubuntu
We still need some manual operation to configure the system. The first step is to boot the Raspberry PI and configure the network attaching the RP to a monitor and a keyboard.
- Login with ubuntu/ubuntu
- Configure the network with netplan
- Enable and start the ssh service

**Can we automate this step?**
## Important notes
> ⚠️ **PORT 8888 for jicofo**
> 
> If the port is busy everything seems to starts but the participants cannot see each others! [issue-6449][1]

[1]: https://github.com/jitsi/jitsi-meet/issues/6449 "Issue 6449"

## Hardware setup
### LCD Display 4.3inch_DSI_LCD
https://www.waveshare.com/wiki/4.3inch_DSI_LCD

### Cooling solution
https://www.arrow.com/en/research-and-events/articles/raspberry-pi-4-cooling-solutions-comparison

https://all3dp.com/2/raspberry-pi-4-heatsink-placement/

With 2 small heatsync and a small fan the temperature is always below 50C.

### Attach the FAN
PIN 4 - 5V - Red cable
PIN 6 - GND - Black cable 

Pin1 is in the opposite from the USB ports on the internal side of the board. For more details see https://www.raspberrypi.org/documentation/usage/gpio/

see https://linuxhint.com/gpio-pinout-raspberry-pi/
## Installation
    sudo apt install openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless openjdk-8-jdk tightvncserver xinit xserver-xorg gnome-tweaks pavucontrol  xserver-xorg-legacy
    sudo apt-get install default-jre-headless ffmpeg curl alsa-utils icewm xdotool xserver-xorg-video-dummy ruby-hocon

### Enable every user to start
```bash
sudo vi /etc/X11/Xwrapper.config
allowed_users=anybody
```

Select Java 8
```bash
update-alternatives --config java # Select openjdk-8
```
  
   
### Chrome installation without snap

Chrome is not compiled anymore for RaspPI therefore we are using Chromium. See [3], [4]

[3]: https://askubuntu.com/questions/1204571/how-to-install-chromium-without-snap
[4]: https://packages.debian.org/bullseye/arm64/apt/download

The default Chromium version is a snap package and it doesn't suit my needs because I need to customize some aspects of the browser.

write the file /etc/apt/sources.list.d/debian.list

```bash
cat <<EOF > /etc/apt/sources.list.d/debian.list
deb [arch=arm64] http://ftp.ch.debian.org/debian bullseye main 
deb [arch=arm64] http://ftp.ch.debian.org/debian bullseye-updates main 
EOF
```

On ubuntu 22.04

```bash
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9 6ED0E7B82643E131 648ACFD622F3D138 605C66F00D6C9793
```

```bash
cat <<EOF >/etc/apt/preferences.d/chromium.pref
# Note: 2 blank lines are required between entries
Package: *
Pin: release a=eoan
Pin-Priority: 500


Package: *
Pin: origin "deb.debian.org"
Pin-Priority: 300


# Pattern includes 'chromium', 'chromium-browser' and similarly
# named dependencies:
Package: chromium*
Pin: origin "deb.debian.org"
Pin-Priority: 700	
EOF
```
Install chromium

```bash
apt update && apt install chromium/oldstable chromium-driver/oldstable
```

To avoid the warning message about the security of the browser we need to disable the security warning.    

```bash
mkdir -p /etc/opt/chrome/policies/managed
echo '{ "CommandLineFlagSecurityWarningsEnabled": false }' >>/etc/opt/chrome/policies/managed/managed_policies.json
```

    https://www.linuxcapable.com/how-to-install-chromium-browser-onq-ubuntu-22-04-lts/
    I need a plain installation to customize it. True?

```bash
wget https://launchpad.net/~xtradeb/+archive/ubuntu/apps/+files/xtradeb-apps-apt-source_0.3_all.deb
apt install ./xtradeb-apps-apt-source_0.3_all.deb

```    
### Install Jitsi
```bash
curl -sL https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo "deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/" | sudo tee /etc/apt/sources.list.d/jitsi-stable.list

sudo apt install jitsi-meet jitsi-meet-prosody jitsi-videobridge2 jitsi-meet-web
```
Set a domain where you have a valid SSL certificate. In our case `translation.sennsolutions.com`

Update SSL Cert. See file update_cert.sh

### Audio Setup - To be confirmed
To work properly Jitsi need the aloop module. It can be found in the package `linux-modules-extra-5.15.0-1015-raspi`

    apt install linux-modules-extra-5.15.0-1015-raspi
    rm /lib/systemd/system/alsa-utils.service ; systemctl daemon-reload
    apt install unzip ffmpeg curl alsa-utils icewm xdotool  xserver-xorg-video-dummy # Why this?

## Chromium installation - To be confirmed

## Jitsi setup
Limit the memory usage
Edit the file /etc/jitsi/videobridge/config and add the following line:
    
    VIDEOBRIDGE_MAX_MEMORY=1024m

And restart the videobridge.

Edit the file  /etc/jitsi/jicofo/config , add the following line:

    JICOFO_MAX_MEMORY=1024m

And restart Jicofo.

### Jitsi customization
Edit the file /etc/jitsi/meet/translation.home.local-config.js
### Recompile jniwrapper-native-1.0-SNAPSHOT
To work properly under ARM64 the jniwrapper-native-1.0-SNAPSHOT.jar must be recompiled. See [gist][2] for more details.

    git clone https://github.com/sctplab/usrsctp.git
    git clone https://github.com/jitsi/jitsi-sctp
    mv ./usrsctp ./jitsi-sctp/usrsctp/
    cd ./jitsi-sctp
    mvn package -DbuildSctp -DbuildNativeWrapper -DdeployNewJnilib -DskipTests

Copy libjnisctp.so

    cp ./jniwrapper/native/target/libjnisctp-linux-aarch64.so \
    ./jniwrapper/native/src/main/resources/lib/linux/libjnisctp.so

Re-package and Copy jniwrapper-native-1.0-SNAPSHOT.jar into Jitsi VideoBridge2

When running mvn package ensure all unit tests are successful. You will see some warnings about "Using platform encoding", but that's fine because we're building on the platform that we intend to run this on anyway.

    mvn package
    sudo cp ./jniwrapper/native/target/jniwrapper-native-1.0-SNAPSHOT.jar \
    /usr/share/jitsi-videobridge/lib/jniwrapper-native-1.0-SNAPSHOT.jar

sudo usermod -aG adm,audio,video,plugdev jibri


[2]: https://gist.github.com/krithin/e50a6001c8435e46cb85f5c6c78e2d66

## SSL Certificate
### SSL Certificate creation
See the document [letsencrypt.md](./letsencrypt.md)
### Nginx SSL Certificate configuration
New file /etc/nginx/sites-available/translation.sennsolution.com.conf with the new domain

### Jitsi SSL Certificate configuration
Cert copied in Jitsi folder following the one configured in the nginx config file
```bash
scp ~/letsencrypt/archive/translation.sennsolutions.com/fullchain1.pem pi@translation.home.local:/tmp/ 	# from bigone
mv /tmp/fullchain1.pem /etc/ssl/translation.sennsolutions.com.crt                         				# on translation

scp ~/letsencrypt/archive/translation.sennsolutions.com/privkey1.pem pi@translation.home.local:/tmp/	# from bigone
mv /tmp/privkey1.pem /etc/ssl/translation.sennsolutions.com.key					                        # on translation

# Create a new Jitsi config with all the domain changed
vi /etc/jitsi/meet/translation.senncolutions.com-config.js

#Update all Jitsi config
cd /etc/jitsi
sed -i=bck 's/home\.local/sennsolutions\.com/' jibri/jibri.conf jicofo/config jicofo/jicofo.conf videobridge/sip-communicator.properties videobridge/config videobridge/jvb.conf


#Update Prosodi
cd /etc/prosody
sed': sed -i.bck 's/translation\.home\.local/translation\.sennsolutions\.com/g' prosody.cfg.lua
cd conf.avail
create a file /etc/prosody/conf.avail/translation.sensolutions.com.cfg.lua with all the domain changed
sed': sed -i.bck 's/translation\.home\.local/translation\.sennsolutions\.com/g' translation.sensolutions.com.cfg.lua
cd ../conf.d
ln -s /etc/prosody/conf.avail/translation.sensolutions.com.cfg.lua

## create the prosody cert
# This certificate is for Prosody. 
# It expires on Jan 14 2024 - Can We make it longer?
# Whats happens if it expires?
cd /etc/prosody/certs
make translation.sennsolutions.com.cnf
make translation.sennsolutions.com.key
make translation.sennsolutions.com.cnf.csr
make translation.sennsolutions.com.cnf.crt
mv translation.sennsolutions.com.cnf.crt translation.sennsolutions.com.crt
mv translation.sennsolutions.com.cnf.key translation.sennsolutions.com.key
mv translation.sennsolutions.com.cnf.csr translation.sennsolutions.com.csr

# Restart the Jitsi services to apply the new config
```

## Enable the NGINX config
```bash
cd /etc/nginx/sites-enabled
ln -s /etc/nginx/sites-available/translation.sennsolution.com.conf
rm translation.home.local.conf
systenctl restart nginx
```
## Prosody setup

    prosodyctl register jibri auth.translation.home.local jibriauthpass
    prosodyctl register recorder recorder.translation.home.local jibrirecorderpass

    ln -s /etc/opt/chrome/policies/ /etc/chromium/ # config for chrome and Chromium are stored in different placeS

## Audio Recording
To record the audio Jibri should be used but I couldn't manage to make it working.
So I am recording the audio with Python intercepting the Audio device.


### Asound conf - Is this used in the last pulse version?
Edit the file /etc/asound.conf 
    pcm.trans {
        type dsnoop
        ipc_key 5678293
        ipc_perm 0666
        ipc_gid audio
      slave {
            pcm "hw:2,0" 
            channels 2 
            #period_size 1024
            #buffer_size 4096
            #rate 48000
            #periods 0 
            #period_time 0
        }
    }

### Create the output sink called recording

    pacmd load-module module-null-sink sink_name=recording sink_properties=device.description=recording

    pacmd list-sinks | egrep '^\s+name: .*'
            name: <alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo>
            name: <alsa_output.platform-bcm2835_audio.stereo-fallback>
            name: <alsa_output.platform-bcm2835_audio.stereo-fallback.2>

The first one is the USB Mic

    pacmd load-module module-combine-sink sink_name=combined sink_properties=device.description=combined slaves=recording,alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo

### Attach the Mic to the sink
    pacmd list-sources | egrep '^\s+name: .*' | grep input
            name: <alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo>

    pacmd load-module module-loopback source=alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo sink=recording latency_msec=1

### Test the recording with PulseAudio
  parecord --channels=2 -d recording.monitor output.wav

### Audio Recording References

- http://mocha.freeshell.org/audio.html
- https://raw.githubusercontent.com/larsimmisch/pyalsaaudio/main/recordtest.py
- https://unix.stackexchange.com/questions/361594/device-or-resource-busy-error-thrown-when-trying-to-record-audio-using-arecord
- https://bbs.archlinux.org/viewtopic.php?id=187258
- https://alsa.opensrc.org/DmixPlugin
- https://alsa.opensrc.org/Dsnoop
- http://larsimmisch.github.io/pyalsaaudio/libalsaaudio.html#examples


### Jupyter setup to record the audio with Python
To start the python recording script I've used Jupyter Notebook with a different port:

    jupyter notebook --ip 0.0.0.0 --port 8889 

A problem that I found, is the difficulty to record the audio while the resource is used by another software. See [gist][5] for more details.

[5]: https://gist.github.com/varqox/c1a5d93d4d685ded539598676f550be8

TOFIX: Add the script to start the recording and or attach the Juypter notebook

## Network setup
## Backend setup

### Node Js
## Frontend setup

## GUI
The small LCD display doesn't allow to have a full GUI. The idea is to have a small display with some buttons to control the meeting.
To be able to control the meeting we need to have a way to interact with the Jitsi server. The idea is to use the Jitsi API to control the meeting. However a GUI is needed and we need to start XWindows to have it with a browser.

Chrome is not anymore available and therefore we are using Chromium with a React App. Chromium is started in a VNC session so that the system can be easily debugged/controlled remotely.

To start Jitsi as moderator you need to be the first to join the meeting. The first user is the moderator and can control the meeting. The moderator can mute all the users and can also unmute a single user.

The preferred way to start Jitsi is with
  
    https://translation.home.local/english#config.startWithAudioMuted=false&config.startWithVideoMuted=true

### GUI Tuning
To enhance the audio recording level I've started pavucontrol and set the Recording device level to 130%.

### VNC Setup
Vncserver is started via systemd with the follow config:
```bash
/etc/systemd/system/vncserver.service
[Unit]
Description=TightVNC server
After=syslog.target network.target

[Service]
Type=forking
User=pi
#PAMName=login
PIDFile=/home/pi/.vnc/%H:1.pid
ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1
ExecStart=/usr/bin/vncserver
ExecStop=/usr/bin/vncserver -kill :1 ; pkill parecord ; pkill pulseaudio

[Install]
WantedBy=multi-user.target
```

#### VNC config
TOFIX: Is the file /home/pi/.xsessionrc relevant?

```bash
.xsessionrc
# Works with vncserver
set -x
exec pulseaudio -v --start -D &
exec icewm --replace &
exec pacmd load-module module-null-sink sink_name=recording sink_properties=device.description=recording && \
pacmd load-module module-combine-sink sink_name=combined sink_properties=device.description=combined slaves=recording,alsa_output.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo && \
pacmd load-module module-loopback source=alsa_input.usb-Creative_Technology_Ltd_Sound_Blaster_Play__3_00252407-00.analog-stereo sink=recording &
exec chromium https://translation.home.local/english &
exec parecord --channels=2 -d recording.monitor /home/pi/output.wav &
```
# Challenge

# Best practices
- Best recording with the Mic at 5-10cm far from the mouth

# Disable the screen dimming -  RO CONFIG

```bash
cat > /home/pi/.xprofile <<EOF
xset s off
xset s noblank
EOF

#Check with xset -q
Screen Saver:
  prefer blanking:  no    allow exposures:  yes
  timeout:  0    cycle:  600

```
https://bbs.archlinux.org/viewtopic.php?id=151590

# RO FS
Before
```bash
Filesystem     1K-blocks    Used Available Use% Mounted on
tmpfs             188908    3248    185660   2% /run
/dev/mmcblk0p2  14975908 9055096   5259600  64% /
tmpfs             944532   25292    919240   3% /dev/shm
tmpfs               5120       4      5116   1% /run/lock
/dev/mmcblk0p1    258095  151512    106583  59% /boot/firmware     <--- THIS MUST STAY AS IS
tmpfs             188904       4    188900   1% /run/user/1000
```

vi /etc/overlayroot.conf
overlayroot="tmpfs"

Be sure that the /boot/firmware/cmdline.txt is not using the root=overlay
`reboot`

After
```bash
Filesystem     1K-blocks    Used Available Use% Mounted on
tmpfs             188908    3248    185660   2% /run
/dev/mmcblk0p2  14975908 9048440   5266256  64% /media/root-ro    <-- THIS IS THE REAL RO ROOT
tmpfs-root        944532  112092    832440  12% /media/root-rw
overlayroot       944532  112092    832440  12% /                 <--- THIS IS THE RW OVERLAY ROOT 
tmpfs             944532    6868    937664   1% /dev/shm
tmpfs               5120       4      5116   1% /run/lock
/dev/mmcblk0p1    258095  151512    106583  59% /boot/firmware    <--- THIS IS LIKE BEFORE
tmpfs             188904       4    188900   1% /run/user/1000

```
sudo overlayroot-chroot to go in a RW view

OR

To disable add `overlayroot=disabled` to the file /boot/firmware/cmdline.txt and reboot

See https://spin.atomicobject.com/2015/03/10/protecting-ubuntu-root-filesystem/


It looks like that the memory isn't limited to half of the available memory. Therefore if anything is writing to much to the FS the system will fail becaus of the lack of memory.

To limit the memory you can do on runtime

Added in the /home/pi/.vnc/xstartup

```bash
```bash
mount -o remount,size=400M /media/root-rw/
```

Unfortunately the tmpfs doesn't solve the problem because when the tmpfs got filled Chrome dies.

Taking a different path disabling all the unuseful logging and writing to the FS.
- disable rsyslogd
  systemctl stop rsyslog.service
- disable dnsmasq logging
  in the file /etc/dnsmasq.d/01-pihole.conf comment the lines:
  #log-queries
  #log-facility=/var/log/pihole/pihole.log

- Auto /var/log clean up
  /usr/local/sbin/cleanup_fs.sh

## References
https://www.golinuxcloud.com/change-tmpfs-partition-size-redhat-linux/
https://www.unix.com/shell-programming-and-scripting/260398-unix-script-cleanup.html


# Monitor the temperature
```bash
#!/usr/bin/env bash

DELAY=${1:-5}
while true; do
    temp=$(vcgencmd measure_temp)
    echo "$(date): $temp"
    sleep $DELAY
done
```

Configured in /usr/local/bin/check_temp.sh



# Disable not useful services
## Auto update
Edit the file `/etc/apt/apt.conf.d/20auto-upgrades` like this:
```bash
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Download-Upgradeable-Packages "0";
APT::Periodic::AutocleanInterval "0";
APT::Periodic::Unattended-Upgrade "0";
``````

## Snap
```bash
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service 
```
https://www.brsmedia.in/how-to-disable-snap-on-ubuntu-22-04/

## Remove snapd completely
Name               Version          Rev    Tracking       Publisher      Notes
bare               1.0              5      latest/stable  canonical✓     base
chromium           116.0.5845.110   2603   latest/stable  canonical✓     -
core20             20230622         1977   latest/stable  canonical✓     base
core22             20230801         867    latest/stable  canonical✓     base
cups               2.4.6-4          981    latest/stable  openprinting✓  -
gnome-3-38-2004    0+git.efb213a    145    latest/stable  canonical✓     -
gnome-42-2204      0+git.ff35a85    127    latest/stable  canonical✓     -
gtk-common-themes  0.1-81-g442e511  1535   latest/stable  canonical✓     -
lxd                5.0.2-838e1b2    24326  5.0/stable/…   canonical✓     -
snapd              2.59.5           19459  latest/stable  canonical✓     snapd


```bash
sudo apt purge snapd

  apport-symptoms avahi-utils blt cups-pk-helper distro-info geoclue-2.0 gir1.2-atk-1.0 gir1.2-freedesktop gir1.2-gdesktopenums-3.0 gir1.2-gdkpixbuf-2.0
  gir1.2-gnomedesktop-3.0 gir1.2-gtk-3.0 gir1.2-handy-1 gir1.2-harfbuzz-0.0 gir1.2-notify-0.7 gir1.2-pango-1.0 gir1.2-polkit-1.0 gir1.2-soup-2.4
  gnome-desktop3-data gnome-settings-daemon gnome-settings-daemon-common gnome-shell-common iio-sensor-proxy libaccountsservice0 libavahi-glib1
  libflashrom1 libftdi1-2 libgeoclue-2-0 libgeocode-glib0 libglu1-mesa libgnome-desktop-3-19 libgweather-3-16 libgweather-common libhandy-1-0
  libimagequant0 liblua5.1-0-dev libncurses-dev libnginx-mod-http-geoip2 libnginx-mod-stream-geoip2 libnm0 libopengl0 libpangoxft-1.0-0
  libpython3.9-minimal libpython3.9-stdlib libraqm0 libreadline-dev libsoup-3.0-0 libsoup-3.0-common libsoup-gnome2.4-1 libtk8.6 libtool-bin libunbound8
  libxkbregistry0 linux-image-5.15.0-52-generic linux-modules-5.15.0-52-generic linux-modules-extra-5.15.0-52-generic lua-any lua-bit32 lua-posix
  lua-readline lua-unbound luarocks mutter-common pastebinit python3-alabaster python3-automat python3-click python3-colorama python3-configobj
  python3-constantly python3-debconf python3-debian python3-distro-info python3-hamcrest python3-hyperlink python3-imagesize python3-incremental
  python3-magic python3-olefile python3-problem-report python3-pyasn1 python3-pyasn1-modules python3-snowballstemmer python3.9 python3.9-minimal run-one
  sphinx-common sphinx-rtd-theme-common squashfs-tools tk8.6-blt2.5 x11-apps x11-session-utils xinput xserver-xorg-input-all xserver-xorg-input-libinput
  xserver-xorg-input-wacom xserver-xorg-legacy xserver-xorg-video-all xserver-xorg-video-amdgpu xserver-xorg-video-ati xserver-xorg-video-fbdev
  xserver-xorg-video-nouveau xserver-xorg-video-radeon xserver-xorg-video-vesa yaru-theme-gnome-shell


sudo apt autoremove 

```

## Cleanup Snap
#!/bin/bash

# Removes old revisions of snaps


```bash
# CLOSE ALL SNAPS BEFORE RUNNING THIS
cat > /usr/local/sbin/clean-snap.sh <<EOF
set -eu
snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        snap remove "$snapname" --revision="$revision"
    done
EOF

chmod +x /usr/local/sbin/clean-snap.sh && /usr/local/sbin/clean-snap.sh
```
# Backup 
Copy the root public key to the translation server

```bash
cd /mnt/bigint/Jitsi_Translation_Raspberrypi
rsync -axP root@translation.sennsolutions.com:/boot/ boot_fs/
rsync -axP root@translation.sennsolutions.com:/ root_fs/
```

# Todo

- Automated Raspberry Pi installation and configuration
- Display how many users are connected
- Show something when the botton Mute All is pressed
- Show when the translator voice is really transmitted
- SSL certificate automated update procedure
- Use the Raspberry Pi as a Wifi Access Point
- RO FS to avoid SD card corruption

# References
https://doganbros.medium.com/jitsi-iframe-in-use-a-shody-guide-to-embeding-jitsi-into-your-website-b13bf8d1c4f6

https://jitsi.org/blog/introducing-the-jitsi-meet-react-sdk/

https://github.com/jitsi/jitsi-meet-react-sdk

https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-iframe/

https://ubunlog.com/en/create-react-app-crea-tu-primera-aplicacion-con-react/

https://stackoverflow.com/questions/55763428/react-native-error-enospc-system-limit-for-number-of-file-watchers-reached

https://stackabuse.com/building-a-rest-api-with-node-and-express/

https://forums.raspberrypi.com/viewtopic.php?t=11444 - How to change the keyboard on Raspbian


https://support.google.com/pixelphone/thread/139593141/local-dns-resolution-suddenly-stopped-working?hl=en-GB


https://android.stackexchange.com/questions/151880/why-is-android-refusing-to-resolve-dns-records-pointing-to-internal-ip-addresses

https://www.androidpolice.com/use-preferred-dns-server-android-tutorial/

https://support.thepihut.com/hc/en-us/articles/360016173477-Pi-4-Pi-400-WiFi-problems

https://reelyactive.github.io/diy/pi-kiosk/

https://blog.logrocket.com/optimizing-performance-react-app/

https://radixweb.com/blog/steps-to-build-react-project-with-create-react-app

https://www.freecodecamp.org/news/how-to-build-a-react-app-different-ways/

https://blog.bitsrc.io/6-best-ways-to-create-a-new-react-application-57b17e5d331a?gi=a22086bee9cb

https://www.copycat.dev/blog/reactjs-build-production/

https://shelcia.medium.com/create-a-video-call-web-app-in-10-minutes-with-jitsi-and-react-5453032f2173

https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ljm-api/#jitsimeetjs

https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ljm-api/

https://www.digitalocean.com/community/tutorials/how-to-deploy-a-react-application-with-nginx-on-ubuntu-20-04