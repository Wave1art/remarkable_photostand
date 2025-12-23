#!/usr/bin/sh

TARGET_URL="http://192.168.0.7:8000/"
MAX_RETRIES=10
RETRY_DELAY=5

echo "Starting network check..."

# Loop to check for internet connectivity
count=0
while [ $count -lt $MAX_RETRIES ]; do
    # Try to ping Google DNS or your target domain once
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        echo "Network is UP. Polling URL..."
        /usr/bin/wget -q -T 10 -O /dev/null "$TARGET_URL"
        exit 0
    else
        echo "Network down, retrying in $RETRY_DELAY seconds... ($((count+1))/$MAX_RETRIES)"
        sleep $RETRY_DELAY
        count=$((count+1))
    fi
done

echo "Network timed out after $MAX_RETRIES attempts."
exit 1