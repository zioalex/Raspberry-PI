- [Intro](#intro)
  - [Consideration](#consideration)
  - [Goals](#goals)
  - [Architecture](#architecture)
- [Requirements](#requirements)
- [Setup](#setup)
  - [Jitsi setup](#jitsi-setup)
  - [Network setup](#network-setup)
  - [Backend setup](#backend-setup)
    - [Jupyter setup](#jupyter-setup)
    - [Node Js](#node-js)
  - [Frontend setup](#frontend-setup)
- [Challenge](#challenge)
- [Todo](#todo)

# Intro

This is the next version of the Translation System. With the legacy system based on Icecast and Darkice we got good the results in terms of easiness of implementation and usabiity but the delay (1-3 secs) is not anymore acceptable.

We are now aiming to have short delay between the original voice and the translation.

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

# Requirements

# Setup

## Jitsi setup
## Network setup
## Backend setup

### Jupyter setup
### Node Js
## Frontend setup

# Challenge

# Todo

- Automated Raspberry Pi installation and configuration
- Display how many users are connected
- Show something when the botton Mute All is pressed
- Show when the translator voice is really transmitted
- SSL certificate automated update procedure
