FROM ubuntu:xenial

RUN \
      DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
      DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
      sudo \
      git-core \
      subversion \
      build-essential \
      gcc-multilib \
      ccache \
      quilt \
      libncurses5-dev \
      zlib1g-dev \
      gawk \
      flex \
      gettext \
      wget \
      unzip \
      python \
      vim \
      libssl-dev && \
      apt-get clean && \
      useradd -m openwrt && \
      echo 'openwrt ALL=NOPASSWD: ALL' > /etc/sudoers.d/openwrt

USER openwrt

WORKDIR /home/openwrt

RUN \
      git clone https://github.com/openwrt/openwrt.git openwrt && \
      cd openwrt && \
      cp feeds.conf.default feeds.conf && \
      ./scripts/feeds update -a; ./scripts/feeds install -a

# install rust
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -yqq curl cargo

RUN sudo curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN bash -c "source $HOME/.cargo/env && rustup target add arm-unknown-linux-musleabi"

RUN echo "source $HOME/.cargo/env" >> $HOME/.bashrc

# install nim
RUN sudo DEBIAN_FRONTEND=noninteractive apt-get install -yqq nim

RUN sudo sed -i 's/arm-linux-gcc/arm-openwrt-linux-gcc/' /etc/nim.cfg

# download languages feed
RUN \
      cd /opt && \
      sudo git clone https://github.com/sartura/languages_feed

# build raspberry pi 3 image
COPY rp3_config rp3_config

RUN \
      cd openwrt && \
      echo "src-link languages /opt/languages_feed" >> feeds.conf && \
      ./scripts/feeds update -a; ./scripts/feeds install -a

RUN cp rp3_config ./openwrt/.config

RUN cd openwrt && make defconfig

RUN cd openwrt && make -j4
