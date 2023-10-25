#!/bin/sh

# Key generation on the server
ssh-keygen -A

# If there is some public key in keys folder
# then it copies its contain in authorized_keys file
if [ "$(ls -A /git-server/rw-keys/)" ]; then
  cd /home/gitrw
  paste -d '\n' /git-server/rw-keys/*.pub > .ssh/authorized_keys
  chown -R gitrw:gitrw .ssh
  chmod 700 .ssh
  chmod -R 600 .ssh/*
fi

# If there is some public key in keys folder
# then it copies its contain in authorized_keys file
if [ "$(ls -A /git-server/ro-keys/)" ]; then
  cd /home/git
  paste -d '\n' /git-server/ro-keys/*.pub > .ssh/authorized_keys
  chown -R git:git .ssh
  chmod 700 .ssh
  chmod -R 600 .ssh/*
fi


# Checking permissions and fixing SGID bit in repos folder
# More info: https://github.com/jkarlosb/git-server-docker/issues/1
if [ "$(ls -A /home/git/repos/)" ]; then
  cd /home/git/repos
  chown -R gitrw:git .
  chmod -R u+rwX,g+rX .
  find . -type d -exec chmod g+s '{}' +
fi

# -D flag avoids executing sshd as a daemon
/usr/sbin/sshd -D
