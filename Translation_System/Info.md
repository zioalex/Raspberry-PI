# TODO
# Create schema
# implementation detail ( icecact chroot, systemd customization, wifi power management disable in /etc/modprobe.d )

disabled udisk2.service to manage with script the mount/umount of the usb key

# Network config
# Admin page
    http://raspberrypiw:8000/admin

## New AP
	eth0 192.168.1.2/24 fixed via DHCP
	wlan0 192.168.1.100 fixed via DHCP

## Translation URL
	http://translation:80/en

# Wifi USB adapter
	Edimax EW-7811Un 150Mbps 11n Wi-Fi USB Adapter
	802.11n WLAN Adapter

#  WLAN AP
	IP 192.168.1.1
	TP-LINK Archer C59

## WIFI CONFIG
	SSID 2.4GHz 
	SSID    Translation 
	KEY     EnglishService

	SSID 5GHz
	SSID    Translation_5G
	KEY     EnglishService

# Admin page
	http://translation/admin

# Status
	http://translation

# Working in progress
Added a new systemd service to start darkice; it is called darkice2 ( add
reference)

	systemctl start darkice2

# Links reference
## Type vs Range
https://www.geckoandfly.com/10041/wireless-wifi-802-11-abgn-router-range-and-distance-comparison/

## USB Audio Dongle problem
https://www.raspberrypi.org/forums/viewtopic.php?f=45&t=132046

## Realtime clock
Not present on the Raspberry Pi2 an external module is needed:
http://www.hobbytronics.co.uk/raspberry-pi-real-time-clock

http://raspberrypi.stackexchange.com/questions/639/how-to-get-pulseaudio-running

http://askubuntu.com/questions/426831/lxde-auto-login

http://raspberrypi.stackexchange.com/questions/32677/setup-microphone-stream-and-turn-your-raspberry-pi-into-a-baby-phone

## Real time audio config with jack
http://wiki.linuxaudio.org/wiki/raspberrypi

## Full project with icecast and darkice
https://stmllr.net/blog/live-mp3-streaming-from-audio-in-with-darkice-and-icecast2-on-raspberry-pi/

## Network configuration in raspberry
https://www.raspberrypi.org/forums/viewtopic.php?t=44044
https://www.raspberrypi.org/forums/viewtopic.php?t=7592

## Custom systemd configs
https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/System_Administrators_Guide/sect-Managing_Services_with_systemd-Unit_Files.html

## Ubuntu and RaspberryPi
https://wiki.ubuntu.com/ARM/RaspberryPi

## Wifi problem with RT5370
https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=40474&start=25

## Disable console screensaver
http://askubuntu.com/questions/138918/how-do-i-disable-the-blank-console-screensaver-on-ubuntu-server

## Udev custom rules
http://askubuntu.com/questions/284224/autorun-a-script-after-i-plugged-or-unplugged-a-usb-device
https://wiki.archlinux.org/index.php/udev#Testing_rules_before_loading

## Raspberry babyphone
http://raspberrypi.stackexchange.com/questions/32677/setup-microphone-stream-and-turn-your-raspberry-pi-into-a-baby-phone
arecord / aplay

## Wireless/Usb Radio Microphone
http://www.bax-shop.nl/usb-microfoon/samson-stage-xpd1-headset-draadloze-usb-microfoon-2-4-ghz?gclid=CMS_pcOm1tACFUmeGwodqkUAMg

## NW problem with WIFI DONGLE. Not solved
https://www.raspberrypi.org/forums/viewtopic.php?t=61665

## CHROOTED ICECAST 
https://forum.sourcefabric.org/discussion/13883/icecast-on-port-80/p1
