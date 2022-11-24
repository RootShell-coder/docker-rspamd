#!/bin/bash

NAME=rspamd

sudo chown -R _rspamd:_rspamd /etc/rspamd/*
sudo /usr/bin/rspamadm configtest -c /etc/rspamd/$NAME.conf
sudo /usr/bin/$NAME -f -u _rspamd -g _rspamd -p /run/rspamd/$NAME.pid -c /etc/rspamd/$NAME.conf
exec "$@"
