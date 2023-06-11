- [Intro](#intro)
  - [Consideration](#consideration)
  - [Goals](#goals)
  - [Architecture](#architecture)
- [Requirements](#requirements)
- [Setup](#setup)
  - [Important notes](#important-notes)
  - [Installation](#installation)
    - [Audio Setup - To be confirmed](#audio-setup---to-be-confirmed)
  - [Chromium installation - To be confirmed](#chromium-installation---to-be-confirmed)
  - [Jitsi setup](#jitsi-setup)
    - [Jitsi customization](#jitsi-customization)
    - [Recompile jniwrapper-native-1.0-SNAPSHOT](#recompile-jniwrapper-native-10-snapshot)
  - [Prosody setup](#prosody-setup)
  - [Audio Recording](#audio-recording)
    - [Asound conf - Is this used in the last pulse version?](#asound-conf---is-this-used-in-the-last-pulse-version)
    - [Create the output sink called recording](#create-the-output-sink-called-recording)
    - [Attach the Mic to the sink](#attach-the-mic-to-the-sink)
  - [Network setup](#network-setup)
  - [Backend setup](#backend-setup)
    - [Jupyter setup](#jupyter-setup)
    - [Node Js](#node-js)
  - [Frontend setup](#frontend-setup)
  - [GUI](#gui)
- [Challenge](#challenge)
- [Todo](#todo)

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
## Important notes
> ⚠️ **PORT 8888 for jicofo**
> 
> If the port is busy everything seems to starts but the participants cannot see each others! [issue-6449][1]

[1]: https://github.com/jitsi/jitsi-meet/issues/6449 "Issue 6449"

## Installation
    sudo apt install openjdk-8-jdk-headless openjdk-8-jre openjdk-8-jre-headless openjdk-8-jdk
    sudo apt-get install default-jre-headless ffmpeg curl alsa-utils icewm xdotool xserver-xorg-video-dummy ruby-hocon

  	sudo usermod -aG adm,audio,video,plugdev jibri

    update-alternatives --config java # Select openjdk-8

### Audio Setup - To be confirmed
To work properly Jitsi need the aloop module. It can be found in the package `linux-modules-extra-5.15.0-1015-raspi`

    apt install linux-modules-extra-5.15.0-1015-raspi
    rm /lib/systemd/system/alsa-utils.service ; systemctl daemon-reload
    apt install unzip ffmpeg curl alsa-utils icewm xdotool  xserver-xorg-video-dummy # Why this?

## Chromium installation - To be confirmed

Chrome is not compiled anymore for RaspPI therefore we are using Chromium. See [3], [4]
[3]: https://askubuntu.com/questions/1204571/how-to-install-chromium-without-snap
[4]: https://packages.debian.org/bullseye/arm64/apt/download

The default Chromium version is a snap package and it doesn't suit my needs because I need to customize some aspects of the browser.

Edit the file /etc/apt/sources.list.d/debian.list and add the following lines:

		deb [arch=arm64] http://ftp.ch.debian.org/debian bullseye main 
		deb [arch=arm64] http://ftp.ch.debian.org/debian bullseye-updates main 

Remove the snap version of Chromium

    sudo apt remove chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg-extra
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CC9673A4F27B8DD47936 62A9605C66F00D6C9793 # 11/bullseye
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys BCDDDC30D7C23CBBABEE # 10/buster Maybe

Update the package list
    vi /etc/apt/preferences.d/chromium.pref
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

Install the normal Chromium package
    apt update && apt install chromium/stable chromium-driver/stable

To avoid the warning message about the security of the browser we need to disable the security warning.    
    mkdir -p /etc/opt/chrome/policies/managed
    echo '{ "CommandLineFlagSecurityWarningsEnabled": false }' >>/etc/opt/chrome/policies/managed/managed_policies.json

    https://www.linuxcapable.com/how-to-install-chromium-browser-on-ubuntu-22-04-lts/
    I need a plain installation to customize it. True?
    See APT Method with PPA
    sudo add-apt-repository ppa:savoury1/chromium -y
    sudo add-apt-repository ppa:savoury1/ffmpeg4 -y
    apt update
    apt install google-chrome-stable
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

[2]: https://gist.github.com/krithin/e50a6001c8435e46cb85f5c6c78e2d66

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

To start the python recording script I've used Jupyter Notebook with a different port:

    jupyter notebook --ip 0.0.0.0 --port 8889 

A problem that I found is the difficulty to record the audio while the resource is used by another software. See [gist][5] for more details.

[5]: https://gist.github.com/varqox/c1a5d93d4d685ded539598676f550be8

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


## Network setup
## Backend setup

### Jupyter setup
### Node Js
## Frontend setup

## GUI
The small LCD display doesn't allow to have a full GUI. The idea is to have a small display with some buttons to control the meeting.
To be able to control the meeting we need to have a way to interact with the Jitsi server. The idea is to use the Jitsi API to control the meeting. However a GUI is needed and we need to start XWindows to have it with a browser.

Chrome is not anymore available and therefore we are using Chromium with a React App. Chromium is started in a VNC session so that the system can be easily debugged/controlled remotely.

# Challenge

# Todo

- Automated Raspberry Pi installation and configuration
- Display how many users are connected
- Show something when the botton Mute All is pressed
- Show when the translator voice is really transmitted
- SSL certificate automated update procedure
- Use the Raspberry Pi as a Wifi Access Point
- RO FS to avoid SD card corruption
