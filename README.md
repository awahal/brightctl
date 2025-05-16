# brightctl
  Automatic brightness control for Linux desktop pc display monitors using ddcutil
  Automatically and gradually lower the brightness of monitors in the evening

# about
  * wrapper for ddcutil to set brightness instantly or gradually
  * systemd units to automate changing brightness at set morning and evening times

# dependencies
  * ddcutil
  ** Ubuntu and Debian systems: ```sudo apt install ddcutil ddcui```
  * monitor that supports VCP code feature 10 (brightness)
  ** ```ddcutil detect``` to view all detected displays
  ** ```ddcutil capabilities --display 1``` (or other display number) and look for verify code 10 "brightness" is in list
  ** ```ddcutil getvcp 10 --display 1``` to check if ddcutil can read display brightness
  * bash
  * systemd

# usage
  ## brightctl.sh
  ```./display-control.sh brightness [time] [display]```
  * brightness = time period in seconds over which to reduce brightness

  example: ```./display-control 50 600 1```
  * Changes Display 1 brightness to 50 over 600 seconds (10 mins)

  example: ```./display-control 100 0 2```
  * Changes Display 2 brightness to 100 instantly

  behavior:
    * ```delay=30``` 30 seconds between brightness change steps
    ** could be lowered for smoother changes or increased for more gradual changes

  defaults if no time or display arguments given:
  * time = 0
  * display = 1 and 2 (currently hard-coded to display_ids=(1 2) in script, may cause issues if not specified and 2 displays are not detected)

# todo:
  * multiple monitor input handling
  * adjustable sleep delay after ddcutil commands
  * adjustable number of steps
  * adjustable sleep delay
  * adjustable time
