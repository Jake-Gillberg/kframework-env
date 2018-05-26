####### VERSIONS #######
FROM debian:stretch

###### GENERIC DOCKER STUFF #######
LABEL maintainer "jake.gillberg@gmail.com"

#Non-interactive console during docker build process
ARG DEBIAN_FRONTEND=noninteractive

#Install apt-utils so debconf doesn't complain about configuration for every
# other install
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
      apt-utils \
  && rm -rf /var/lib/apt/lists/*

#Set the locale
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    locales \
  && rm -rf /var/lib/apt/lists/* \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && dpkg-reconfigure locales \
  && echo ': "${LANG:=en_US.utf8}"; export LANG' >> /etc/profile

#Start the entrypoint script
RUN echo '#!/bin/bash' > entrypoint.sh \
  && chmod 0700 /entrypoint.sh

#Create regular user (dev) and groups
RUN \
  adduser --gecos "" --shell /bin/bash --disabled-password dev

####### KFRAMEWORK #######

# Dependencies
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
      aspcud \
      build-essential \
      darcs \
      flex \
      git \
      libfl-dev \
      libgmp-dev \
      libmpfr-dev \
      libz3-dev \
      m4 \
      maven \
      mercurial \
      ocaml \
      opam \
      openjdk-8-jdk \
      pkg-config \
      python3 \
      rsync \
      z3 \
  && rm -rf /var/lib/apt/lists/*

# Clone and install
RUN \
  git clone --depth=1 https://github.com/kframework/k5.git \
  && chown -hR dev:dev k5
WORKDIR /k5
USER dev
RUN \
  mvn package \
  && k-distribution/target/release/k/bin/k-configure-opam \
  && opam config setup -a
WORKDIR /
USER root
RUN \
  chown -hR root:root k5

# Update PROFILE
RUN \
  echo ''                                                              >> /home/dev/.profile \
  && echo 'if [ -d "/k5/k-distribution/target/release/k/bin" ] ; then' >> /home/dev/.profile \
  && echo '    PATH="/k5/k-distribution/target/release/k/bin:$PATH"'   >> /home/dev/.profile \
  && echo 'fi'                                                         >> /home/dev/.profile

####### VIM #######
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
    vim \
    curl \
  && rm -rf /var/lib/apt/lists/*

# Copy user vimrc
COPY ./customize/.vimrc /home/dev/.vimrc.bak
RUN chown dev:dev /home/dev/.vimrc.bak \
  && chmod 0644 /home/dev/.vimrc.bak

USER dev

RUN \
  # Install pathogen - plugin manager
    mkdir -p /home/dev/.vim/autoload /home/dev/.vim/bundle \
    && curl -LSo /home/dev/.vim/autoload/pathogen.vim \
                 https://raw.githubusercontent.com/tpope/vim-pathogen/master/autoload/pathogen.vim \
    #Configure pathogen
    #Delete following lines if your vimrc enables pathogen
      && echo '"Turn on plugin manager' >> /home/dev/.vimrc \
      && echo 'execute pathogen#infect()' >> /home/dev/.vimrc \
  # Install sensible - mostly uncontentious defaults
    && git clone --depth=1 https://github.com/tpope/vim-sensible.git /home/dev/.vim/bundle/sensible \
  # Install vim-kframework
    && mkdir -p /home/dev/.vim/bundle/vim-kframework/syntax \
    && curl -LSo /home/dev/.vim/bundle/vim-kframework/syntax/kframework.vim \
                 https://raw.githubusercontent.com/kframework/k-editor-support/master/vim/kframework.vim \
    && mkdir /home/dev/.vim/bundle/vim-kframework/ftdetect \
    && echo 'au BufRead,BufNewFile *.k set filetype=kframework' \
            > /home/dev/.vim/bundle/vim-kframework/ftdetect/kframework.vim \
  # apply customized vimrc
    && echo '' >> /home/dev/.vimrc \
    && cat /home/dev/.vimrc.bak >> /home/dev/.vimrc

USER root

####### STARTUP #######
RUN \
  apt-get update \
  && apt-get install -y --no-install-recommends \
      gosu \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /tmp/* \
  && echo 'exec gosu dev /bin/bash' >> /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
