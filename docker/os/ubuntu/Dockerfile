FROM ubuntu:latest
LABEL maintainer="Eric Wilson <eric.wilson@geekcafe.com>"

ARG USER_NAME="geek"
ARG USER_PASSWORD="g33k001"

ENV USER_NAME $USER_NAME
ENV USER_PASSWORD $USER_PASSWORD
ENV CONTAINER_IMAGE_VER=v1.0.0

RUN echo $USER_NAME
RUN echo $USER_PASSWORD
RUN echo $CONTAINER_IMAGE_VER

# install the tooks i wish to use
RUN apt-get update && \
  apt-get install -y sudo \
  curl \
  git-core \
  gnupg \
  linuxbrew-wrapper \
  locales \
  nodejs \
  zsh \
  wget \
  nano \
  npm \å
  fonts-powerline \
  # set up locale
  && locale-gen en_US.UTF-8 \
  # add a user (--disabled-password: the user won't be able to use the account until the password is set)
  && adduser --quiet --disabled-password --shell /bin/zsh --home /home/$USER_NAME --gecos "User" $USER_NAME \
  # update the password
  && echo "${USER_NAME}:${USER_PASSWORD}" | chpasswd && usermod -aG sudo $USER_NAME

  
  # the user we're applying this too (otherwise it most likely install for root)
  USER $USER_NAME
  # terminal colors with xterm
  ENV TERM xterm
  # set the zsh theme
  ENV ZSH_THEME agnoster

  # run the installation script  
  RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true

  # start zsh
  CMD [ "zsh" ]


