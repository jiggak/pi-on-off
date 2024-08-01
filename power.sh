#!/bin/bash

HALT_PIN=4    # halt by GPIO-4 (BCM naming)
SYSUP_PIN=17  # output SYS_UP signal on GPIO-17 (BCM naming)
I2C_MC_ADDRESS=0x69

export PATH=/usr/bin:/usr/sbin:/storage/.kodi/addons/virtual.system-tools/bin
export LD_LIBRARY_PATH=/usr/lib:/storage/.kodi/addons/virtual.system-tools/lib:/usr/lib/pulseaudio

gpio_in() {
  gpioget --numeric -c gpiochip0 $1
}

gpio_out() {
  # https://stackoverflow.com/questions/77441261/is-it-possible-for-gpioset-version-2-0-2-to-exit-immediately
  # There might we a way to make gpioget perform the toggle with single call
  # Instead of what I'm doing by calling it twice below
  gpioset -t0 -c gpiochip0 ${1}=$2
}

gpio_wait() {
  gpiomon --quiet --num-events=1 --edges=falling --bias=pull-up -c gpiochip0 $1
}

# wait for RTC ready
sleep 2

# indicates system is up
echo "Send out the SYS_UP signal via GPIO-$SYSUP_PIN pin."
gpio_out ${SYSUP_PIN} 1
sleep 0.5
gpio_out ${SYSUP_PIN} 0

# delay until GPIO pin state gets stable
counter=0
while [ $counter -lt 5 ]; do  # increase this value if it needs more time
  if [ $(gpio_in $HALT_PIN) == "1" ] ; then
    counter=$(($counter+1))
  else
    counter=0
  fi
  sleep 1
done

# wait for GPIO-4 (BCM naming) falling
echo "Waiting for shutdown command..."
gpio_wait $HALT_PIN

# shutdown Raspberry Pi
echo "Shutdown"
halt