ARG DEBIAN_VERSION=bookworm-slim
ARG BASEDEV_VERSION=v0.24.0

FROM debian:${DEBIAN_VERSION} AS chktex
ARG CHKTEX_VERSION=1.7.8
WORKDIR /tmp/workdir
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends g++ make wget libpcre2-dev perl
RUN wget -qO- http://download.savannah.gnu.org/releases/chktex/chktex-${CHKTEX_VERSION}.tar.gz | \
  tar -xz --strip-components=1
RUN ./configure && \
  make && \
  mv chktex /tmp && \
  rm -r *

FROM qmcgaw/basedevcontainer:${BASEDEV_VERSION}-debian
WORKDIR /tmp/texlive
ARG SCHEME=scheme-basic
ARG DOCFILES=0
ARG SRCFILES=0
ARG TEXLIVE_VERSION=2023
ARG TEXLIVE_MIRROR=http://ctan.math.utah.edu/ctan/tex-archive/systems/texlive/tlnet
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends wget gnupg cpanminus && \
  wget -qO- ${TEXLIVE_MIRROR}/install-tl-unx.tar.gz | \
  tar -xz --strip-components=1 && \
  export TEXLIVE_INSTALL_NO_CONTEXT_CACHE=1 && \
  export TEXLIVE_INSTALL_NO_WELCOME=1 && \
  printf "selected_scheme ${SCHEME}\ninstopt_letter 0\ntlpdbopt_autobackup 0\ntlpdbopt_desktop_integration 0\ntlpdbopt_file_assocs 0\ntlpdbopt_install_docfiles ${DOCFILES}\ntlpdbopt_install_srcfiles ${SRCFILES}" > profile.txt && \
  perl install-tl -profile profile.txt --location ${TEXLIVE_MIRROR} && \
  ln -sf /usr/local/texlive/${TEXLIVE_VERSION}/bin/$(uname -m)-linux /usr/local/texlive/bin && \
  # Cleanup
  cd && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/ /tmp/texlive /usr/local/texlive/${TEXLIVE_VERSION}/*.log

ENV PATH="/usr/local/texlive/bin:$PATH"
WORKDIR /workspace
RUN apt-get update -y && \
  apt-get install -y --no-install-recommends cpanminus make gcc libc6-dev && \
  cpanm -n -q Log::Log4perl && \
  cpanm -n -q XString && \
  cpanm -n -q Log::Dispatch::File && \
  cpanm -n -q YAML::Tiny && \
  cpanm -n -q File::HomeDir && \
  cpanm -n -q Unicode::GCString && \
  apt-get remove -y cpanminus make gcc libc6-dev && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  fonts-ipafont \
  fonts-ipaexfont \
  fonts-noto-cjk \
  fonts-noto-cjk-extra \
  fonts-texgyre && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/{apt,dpkg,cache,log}/

RUN tlmgr update --self && \
  tlmgr install \
  collection-bibtexextra \
  collection-fontsrecommended \
  collection-langenglish \
  collection-langjapanese \
  collection-latexextra \
  collection-latexrecommended \
  collection-mathscience \
  latexdiff \
  siunitx \
  newtx \
  svg \ 
  minted \
  plantuml \
  graphviz \
  latexindent \
  latexmk && \
  rm /usr/local/texlive/${TEXLIVE_VERSION}/texmf-var/web2c/*.log && \
  rm /usr/local/texlive/${TEXLIVE_VERSION}/tlpkg/texlive.tlpdb.main.*

COPY --from=chktex /tmp/chktex /usr/local/bin/chktex
COPY shell/.zshrc-specific shell/.welcome.sh /root/
# Verify binaries work and have the right permissions
RUN tlmgr version && \
  latexmk -version && \
  texhash --version && \
  chktex --version
