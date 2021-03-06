FROM debian

RUN apt-get update
RUN apt full-upgrade -y
RUN apt install -y git-core avrdude wget bzip2

RUN apt install -y gperf bison flex texinfo help2man build-essential
RUN apt install -y gawk libtool-bin automake libncurses5-dev
RUN apt install -y gcc-avr binutils-avr avr-libc arduino-mk
RUN cd $HOME && wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.22.0.tar.bz2
RUN cd $HOME && tar -xvf crosstool-ng-1.22.0.tar.bz2
RUN cd $HOME/crosstool-ng && ./configure --prefix=/opt/cross
RUN cd $HOME/crosstool-ng && make -j4 && make install
RUN apt install -y sudo

RUN export uid=1000 gid=1000 && \
  mkdir -p /home/developer && \
  echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
  echo "developer:x:${uid}:" >> /etc/group && \
  echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
  chmod 0440 /etc/sudoers.d/developer && \
  chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer
ENV PATH "$HOME/ib:/opt/cross/bin:$PATH"
ADD ct-ng.config $HOME/.config
RUN sudo chown -R developer /opt/cross
RUN cd $HOME && ls && ct-ng build
ENV PATH "/opt/cross/x-tools/arm-unknown-linux-gnueabi/bin/:$PATH"
RUN sudo apt install -y python
RUN cd $HOME && git clone https://github.com/JasonL9000/ib
