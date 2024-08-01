Turn on the Raspberry Pi, and gracefully power-off, using a USB device as a
switch (Such as a TV with a USB port). When 5v is detected the Raspberry Pi boots.
Using the script `power.sh` the Pi will halt, then power-off, when power on the
USB power is cut.

* Raspberry Pi 4
* [Witty Pi 4 Mini](https://www.uugear.com/product/witty-pi-4-mini/)
* [LibreELEC 12.0](https://libreelec.tv/)

## Required Packages

Install LibreELEC "System Tools" add-on to get gpio and i2c commands.

> The `power.sh` script uses syntax specific to the 2.x version of the gpio tools,
> provided by [libgpiod](https://github.com/brgl/libgpiod/blob/master/NEWS).

##

## Install

Copy `power.sh` to `/storage/scripts/power.sh`.

Create systemd service definition `/storage/.config/system.d/power.service`

```
[Unit]
Description=WittyPi power control

[Service]
Type=simple
User=root
ExecStart=/bin/bash /storage/scripts/power.sh

[Install]
WantedBy=multi-user.target
```

Enable the service and start it

```bash
systemctl enable power.service
systemctl start power.service
```

## Setup Witty-Pi

The Witty-Pi requires a few tweaks. This only needs to be run once, or after the
Witty-Pi has been disconnected long enough to discharge the super capacitor.

```bash
# set low voltage, 0x14 = 2.0v
# When USB voltage goes below this, the Witty-Pi will send shutdown signal,
# then power-off after the configured delay.
i2cset -y 0x01 0x08 19 0x14

# set recovery voltage, 0x28 = 4.0v
# When USB voltage goes above this, the Witty-Pi will power-on the Pi.
i2cset -y 0x01 0x08 22 0x28

# set delay (in 10/s of a seconds) before power cut, 0x78 (1200) = 12s
i2cset -y 0x01 0x08 21 0x78

# set ignore flags to make power on/off with vin
i2cset -y 1 8 41 1 # I2C_CONF_IGNORE_POWER_MODE
```


## Helpful i2c Commands

```bash
# get firmware version
i2cget -y 0x01 0x08 0

# get low voltage, 0x14 = 2.0v
i2cget -y 0x01 0x08 19

# get recovery voltage, 0x28 = 4.0v
i2cget -y 0x01 0x08 22

# get power cut delay, 0x78 (1200) = 12s
i2cget -y 0x01 0x08 21
```

## Known Issues

**This is not required on latest Witty-Pi Mini hardware revision.**

Need to add capacitor on 3.3v pin to fix problem where Witty-Pi briefly lights up
and shutsdown when attempting to power on Pi.

https://www.uugear.com/forums/technial-support-discussion/witty-pi-4-tapping-the-on-off-switch-doesnt-turn-on-the-raspberry-pi/