#!/usr/bin/env zsh

status() {
    echo -n "$STATUS"
}

toggle() {
    STATUS_SET=('connected' 'disconnected')
    COMMAND_SET=('connect' 'disconnect')

    # replace current object in array with "/" and get index
    INDEX=`echo ${STATUS_SET[@]/$STATUS//} | cut -d/ -f1 | wc -w | tr -d ' '`

    INDEX=$[$INDEX+1]

    if [ $INDEX -lt ${#STATUS_SET[@]} ]
    then
        INDEX=$[$INDEX+1]
    else
        INDEX=1
    fi

    mullvad ${COMMAND_SET[$INDEX]} > /dev/null
}

reconnect() {
    mullvad reconnect > /dev/null
}

STATUS=`mullvad status | cut -d ' ' -f3 | tr '[:upper:]' '[:lower:]'`

case $1 in
	"status") status;;
	"toggle") toggle;;
	"reconnect") reconnect;;
esac
