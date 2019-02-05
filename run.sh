#!/bin/sh

if [ -z "$LOGGLY_ENV" ]; then
  echo "Missing \$LOGGLY_ENV"
  exit 1
fi

if [ "$LOGGLY_ENV" != "development" ]; then
  if [ -z "$LOGGLY_AUTH_TOKEN" ]; then
    echo "Missing \$LOGGLY_AUTH_TOKEN"
    exit 1
  fi

  if [ -z "$LOGGLY_TAG" ]; then
    echo "Missing \$LOGGLY_TAG"
    exit 1
  fi
fi

# Create spool directory
mkdir -p /var/spool/rsyslog

# Expand multiple tags, in the format of tag1:tag2:tag3, into several tag arguments
LOGGLY_TAG=$(echo "$LOGGLY_TAG:$LOGGLY_ENV" | sed 's/:/\\\\" tag=\\\\"/g')

# Replace variables
sed -i "s/LOGGLY_AUTH_TOKEN/$LOGGLY_AUTH_TOKEN/" /etc/rsyslog.conf
sed -i "s/LOGGLY_TAG/$LOGGLY_TAG/" /etc/rsyslog.conf

if [ "$LOGGLY_ENV" = "development" ]; then
  echo "*.* :omstdout:" >> /etc/rsyslog.conf
else
  echo "*.* @@logs-01.loggly.com:6514;LogglyFormat" >> /etc/rsyslog.conf
fi

# Run RSyslog daemon
exec /usr/sbin/rsyslogd -n