# brightctl
Automatic brightness control for Linux desktop pc display monitors using ddcutil

## about
* Work In Progress!
* Automatically and gradually lower the brightness of monitors in the evening
* wrapper for ddcutil to set brightness instantly or gradually
* systemd units to automate changing brightness at set morning and evening times

# dependencies
* ddcutil
  * Ubuntu and Debian systems: ```sudo apt install ddcutil```
* monitor that supports VCP feature code 10 (brightness)
  * ```ddcutil detect``` to view all detected displays
  * ```ddcutil capabilities --display 1``` (or other display number) and look for verify code 10 "brightness" is in list
  * ```ddcutil getvcp 10 --display 1``` to check if ddcutil can read display brightness

# install
* move brightctl.sh and run_brightctl.sh to ~/.local/bin and make executable (chmod +x)
* move systemd files to your local user systemd folder ~/.config/systemd/user
* install systemd units as user: 
  ```
  systemctl --user daemon-reload
  systemctl --user enable brightctl-day.service
  systemctl --user enable brightctl-day.timer
  systemctl --user enable brightctl-night.service
  systemctl --user enable brightctl-night.timer
  systemctl --user enable brightctl-session.service
  ```

# usage
## brightctl.sh
* ```./brightctl.sh brightness time display```
  
  brightness = time period in seconds over which to reduce brightness

* ex: ```./brightctl 50 600 1```

  Changes Display 1 brightness to 50 over 600 seconds (10 mins)

* ex: ```./brightctl 100 0 2```

  Sets Display 2 brightness to 100 instantly

* ex: ```./brightctl 100```

  Sets Display 1 and 2 brightness to 100 instantly

* ex: ```./brightctl 25 3600```

  Sets Display 1 and 2 brightness to 25 gradually over 30 minutes

behavior:
* ```delay=30``` 30 seconds between brightness change steps

defaults if no time or display arguments given:
* time = 0
* display = 1 and 2 (currently hard-coded to display_ids=(1 2) in script, may cause issues if not specified and 2 displays are not detected)

## run_brightctl.sh
* script to handle setting brightness at boot or resuming from suspend
* current values: 8am brightness = 100, 8pm brightness = 33, 
* behavior: immediately sets display brightness to 100 if ran after 8am (booting up PC in morning)
* immediately sets display brightness to 33 if ran after 8pm (resuming PC from sleep at night)

## systemd units
* brightctl-(day/night).timer runs brightctl-(day/night).service
* timers run at time: ```OnCalendar=*-*-* 08:00:00```
* brightctl-day.service executes: brightctl.sh 100 (instantly set monitors to 100 at 8am)
* brightctl-night.service executes: brightctl.sh 33 1800 (gradually sets displays' brightness to 33 over 30 minutes)
* brightctl-session.service: adjusts brightness display at boot or login by executing run_brightctl.sh

### todo:
* argparsing
* multiple monitor input handling
* adjustable sleep delay after ddcutil commands
* adjustable number of steps
* adjustable sleep delay
* adjustable morning and evening times
* morning needs gradual brightness change
