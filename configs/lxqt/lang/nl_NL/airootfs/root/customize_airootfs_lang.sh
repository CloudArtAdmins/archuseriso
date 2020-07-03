#!/bin/bash

set -e -u

# nl_NL.UTF-8 locales
sed -i 's/#\(nl_NL\.UTF-8\)/\1/' /etc/locale.gen
locale-gen

# Netherlands, Amsterdam timezone
ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
