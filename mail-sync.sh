#!/bin/bash

# Configuration
SYNC_INTERVAL=60

while true; do
    # Run mbsync for all accounts
    mbsync -a

    # Get unread count before indexing
    PREV_UNREAD=$(notmuch count tag:unread)

    # Index new mail
    notmuch new

    # Get new unread count
    CURRENT_UNREAD=$(notmuch count tag:unread)

    # If new mail arrived, send a notification
    if [ "$CURRENT_UNREAD" -gt "$PREV_UNREAD" ]; then
        NEW_COUNT=$((CURRENT_UNREAD - PREV_UNREAD))
        notify-send "📧 New Mail" "You have $NEW_COUNT new message(s)." -a "aerc" -i mail-unread
    fi

    sleep $SYNC_INTERVAL
done
