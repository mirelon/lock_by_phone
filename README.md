lock_by_phone
=============

Background job that will detect your leave from computer and locks it. Using ping on your mobile phone.

Usage:

for the first run:
1. find ip address of your phone (settings -> wifi -> details -> ip address)
2. find mac address of your phone (settings -> about phone -> status -> wi-fi mac address)
./lock_by_phone.sh <MAC_ADDRESS> <IP_ADDRESS>

for next runs:

./lock_by_phone.sh <MAC_ADDRESS>
it will detect ip address of your phone automatically

