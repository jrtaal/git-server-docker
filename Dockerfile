FROM alpine:3.18.4

LABEL MAINTAINER="jacco.taal@gmail.com"

# "--no-cache" is new in Alpine 3.3 and it avoid using
# "--update + rm -rf /var/cache/apk/*" (to remove cache)
RUN apk add --no-cache \
# openssh=7.2_p2-r1 \
  openssh \
# git=2.8.3-r0
  git


# SSH autorun
# RUN rc-update add sshd

WORKDIR /git-server/

# -D flag avoids password generation
# -s flag changes user's shell
RUN mkdir /git-server/rw-keys \
  && mkdir /git-server/ro-keys  \
  && adduser -D -s /usr/bin/git-shell-ro git \
  && adduser -D -s /usr/bin/git-shell gitrw \
  && addgroup git gitrw \
  && echo git:`pwgen 10 1` | chpasswd \
  && echo gitrw:`pwgen 10 1` | chpasswd \
  && mkdir /home/git/.ssh \
  && mkdir /home/gitrw/.ssh \
  && mkdir /home/gitrw/repo \
  && chown -R gitrw:gitrw /home/gitrw/repo \
  && git config --global init.defaultBranch main \
  && ln -s /home/gitrw/repo /home/git/repo


# This is a login shell for SSH accounts to provide restricted Git access.
# It permits execution only of server-side Git commands implementing the
# pull/push functionality, plus custom commands present in a subdirectory
# named git-shell-commands in the user’s home directory.

# More info: https://git-scm.com/docs/git-shell
COPY git-shell-commands /home/gitrw/git-shell-commands

# sshd_config file is edited for enable access key and disable access password
COPY sshd_config /etc/ssh/sshd_config
COPY start.sh start.sh
COPY git-shell-ro /usr/bin/

EXPOSE 22

CMD ["sh", "start.sh"]
