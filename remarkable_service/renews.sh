#!/usr/bin/sh

BASE_URL="http://192.168.0.7:8000"
HEALTH_URL="health"
# TARGET_URL="image"
TARGET_URL=""
MAX_RETRIES=10
RETRY_DELAY=5

echo "Starting network check..."

# Loop to check for internet connectivity
count=0
while [ $count -lt $MAX_RETRIES ]; do
    # Try to ping Google DNS or your target domain once
    # if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    if /usr/bin/wget -q -T 5 --spider "$BASE_URL/$HEALTH_URL"; then
        echo "Network is UP. Getting latest image"
        # /usr/bin/wget -q -T 10 -O /dev/null "$BASE_URL/"

        /home/root/bin/renews.arm \
            -output /usr/share/remarkable/suspended.png \
            -url "$BASE_URL/$TARGET_URL" \
            -mode fill \
            -test

        # Set the next wakeup time to be in 2 minutes   
        echo 0 > /sys/class/rtc/rtc0/wakealarm
        echo $(( $(date '+%s') + 120)) > /sys/class/rtc/rtc0/wakealarm

        exit 0
    else
        echo "Network down, retrying in $RETRY_DELAY seconds... ($((count+1))/$MAX_RETRIES)"
        sleep $RETRY_DELAY
        count=$((count+1))
    fi
done

echo "Network timed out after $MAX_RETRIES attempts."
exit 1