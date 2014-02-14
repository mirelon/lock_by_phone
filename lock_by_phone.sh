#!/bin/bash

# pings in one batch
TOTAL_PINGS=3

# how many successful pings needed to consider device as reachable
PING_THRESHOLD=1

# interval between ping batches in seconds
PING_BATCH_INTERVAL=5

# after device unreachability detected, in seconds
SLEEP_TIMEOUT=30

# command to run background job that will put computer to sleep
DELAYED_LOCK_JOB="./delayed_lock.sh $SLEEP_TIMEOUT"

#mac address of the device, for now the default is mine
MAC_ADDRESS="8c:77:16:57:c5:2f"

if [ $# -gt 0 ]
then
  MAC_ADDRESS=$1
fi

function install() {
  # add ip address and mac address to arp table

  echo "install(): adding arp entry for ip=$IP and mac=$MAC_ADDRESS"
  
  sudo arp -s $IP $MAC_ADDRESS

  # arp -av
}

function init() {
  
  # find ip address of my phone:
  echo "init(): sending arp packet to detect devices in order to find my phone"

  IP=`arp | grep 8c:77:16:57:c5:2f | awk '{print $1}'`
  if [ -z $IP ]
  then
    echo "Run this script with two parameters, first MAC address of the device and second the IP addess in order to add an entry to local ARP table"
    exit
  fi

}

function perform() {
  echo "perform()"
  if [ -z $IP ]
  then
    echo "Do not know IP address of the device, exitting"
    exit
  fi
  
  # find out how many pings were successful:

  while true
  do
    echo "pinging device with $TOTAL_PINGS pings"
    PING_OUTPUT=`ping $IP -c $TOTAL_PINGS`
    SUCCESSFUL_PINGS=`echo $PING_OUTPUT | grep transmitted | sed -e 's/.* \([0-9]*\) received.*/\1/'`
    if [ $SUCCESSFUL_PINGS -lt $PING_THRESHOLD ]
    then
      echo -e "\e[33mDevice unreachable, move your mouse to prevent locking\e[0m"
      DELAYED_LOCK_JOB_PID=`ps ax | grep -e "${DELAYED_LOCK_JOB}" | grep -v grep | awk '{print $1}'`
      if [ -z $DELAYED_LOCK_JOB_PID ]
      then
        echo "starting delayed lock"
        eval ${DELAYED_LOCK_JOB} &
      else
        echo "delayed lock is already running with pid $DELAYED_LOCK_JOB_PID"
      fi
    else
      echo "Device OK, pings $SUCCESSFUL_PINGS/$TOTAL_PINGS"
      DELAYED_LOCK_JOB_PID=`ps ax | grep -e "${DELAYED_LOCK_JOB}" | grep -v grep | awk '{print $1}'`
      if [ ! -z $DELAYED_LOCK_JOB_PID ]
      then
        echo "Killing a delayed lock process with pid=$DELAYED_LOCK_JOB_PID"
        kill $DELAYED_LOCK_JOB_PID
      fi
    fi
    
    
    sleep $PING_BATCH_INTERVAL
  done
  
}

if [ $# -eq 2 ]
then
  IP=$2
  install
fi

if [ -z $IP ]
then
  init
fi
perform