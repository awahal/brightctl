# brightctl
Schedule smooth brightness control for *Linux Desktop* display monitors using [ddcutil](https://github.com/rockowitz/ddcutil)

* set brightness of 1 or more displays from the command line
* gradually raise or lower brightness of displays
* systemd timers and script to schedule brightness changes

#### about:
I wanted to automatically and gently lower the brightness of my pc monitors in the evening. Work in progress!

* scripts for ```ddcutil``` to set brightness instantly or gradually for 1 or more displays
* systemd services and helper script to automatically set brightness at morning and evening time

## usage
:warning: **Warning! Black Screen/No Brightness:** Before setting brightness to 0, test low brightness values (0-100) for screen visibility 
* Use of monitor controls and on-screen display menu may be necessary to raise brightness

#### brightctl.sh
```
./brightctl.sh <brightness> [time] [display]
```

```brightness```: integer value from 0 to 100

```time```:  # of secs, *default = 0*
* time period to change brightness over

```display```: ddcutil Display id, *default = 1*
* default display numbering starts at 1
* ```ddcutil detect``` to see all connected displays

#### examples
```./brightctl.sh 50 600 1```
* changes Display 1 brightness to 50 over 600 seconds (10 mins)

```brightctl.sh 100 0 2```
(*omit "./" if brightctl.sh is in current work dir, .local/bin, or in $path*)
* sets Display 2 brightness to 100 instantly

```brightctl.sh 100```
* sets Default Display (Display 1) brightness to 100 instantly
  
```brightctl.sh 25 3600```
* sets Default Display (Display 1) brightness to 25 gradually over 30 minutes

#### dependencies
* ddcutil
* Ubuntu and Debian systems: ```sudo apt install ddcutil```
 * monitor that supports VCP feature code 0x10 (brightness)
* ```ddcutil detect``` to view all detected displays
* ```ddcutil capabilities --display 1``` *or other display*
 * ```Feature: 10 (Brightness)``` should be listed under ```VCP Features:```
* ```ddcutil getvcp 10 --display 1``` to verify that ddcutil can read display brightness

## install
* Run ```./install.sh```
  
#### manual installation:
* copy brightctl.sh and run_brightctl.sh to `~/.local/bin` and make executable (chmod 755)
* copy files in systemd folder to your local user systemd folder `~/.config/systemd/user` and set permissions (chmod 644)
* enable systemd units as user: 
```
systemctl --user daemon-reload
systemctl --user enable brightctl-day.timer brightctl-night.timer brightctl-session.service
systemctl --user start brightctl-day.timer brightctl-night.timer
```
#### uninstall
* disable/remove systemd units and script files
```
systemctl --user disable brightctl-day.timer brightctl-night.timer brightctl-session.service
systemctl --user daemon-reload
rm ~/.config/systemd/user/brightctl*
rm ~/.local/bin/*brightctl.sh
```

## program behavior and control
##### brightctl.sh
```delay=30``` 
* 30 seconds between brightness change steps for less noticeable screen flickering
```sleep 5``` 
* sleeps after ddcutil commands due to ddc delays
morning and night times and brightness levels:
 * set in .timer unit files and run_brightctl.sh
 * currently set to 100 at 08:00 and 33 at 20:00

defaults if no time or display arguments given:
* time = 0
* display = 1 (edit default=1) in brightctl.sh

#### run_brightctl.sh
* script to handle setting brightness at boot or resuming from suspend
* current values: 8am brightness = 100, 8pm brightness = 33, 
* behavior: immediately sets display brightness to 100 if ran after 8am (booting up PC in morning)
* immediately sets display brightness to 33 if ran after 8pm (resuming PC from sleep at night)

#### systemd units
* brightctl-(day/night).timer runs brightctl-(day/night).service
* timers run at time: ```OnCalendar=*-*-* 08:00:00```
* brightctl-day.service executes: brightctl.sh 100 (instantly set monitors to 100 at 8am)
* brightctl-night.service executes: brightctl.sh 33 1800 (gradually sets displays' brightness to 33 over 30 minutes)
* brightctl-session.service: adjusts brightness display at boot or login by executing run_brightctl.sh

### todo:
argparsing for:
- [ ] multiple monitor input handling
- [ ] sleep delay after ddcutil commands
- [ ] number of steps
- [ ] sleep delay between steps

enable program settings for:
- [ ] configurable morning and evening times
- [ ] brightness transition period

ideas:
- [ ] percentage/relative adjustment of brightness in brightctl
- [ ] auto-dim when system is idle
- [ ] automatically follow sunset/sunrise
- [ ] follow system light/dark theme schedule


#### License
MIT License Attached. Not liable for your screen or gpu catching fire
