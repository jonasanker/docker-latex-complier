FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive

# Setup common dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
           apt-transport-https \
           ca-certificates \
           dirmngr \
           ghostscript \
           gnupg \
           gosu \
           make \
           perl

# Install MikTex
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D6BC243565B2087BC3F897C9277A7293F59E4889
RUN echo "deb http://miktex.org/download/ubuntu focal universe" | tee /etc/apt/sources.list.d/miktex.list

RUN apt-get update \
    && apt-get install -y --no-install-recommends miktex

# Install Python and PIP
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip

# Install Pygmtens
RUN pip3 install Pygments

# MikTex location
ENV MIKTEX_USERCONFIG=/miktex/.miktex/texmfs/config
ENV MIKTEX_USERDATA=/miktex/.miktex/texmfs/data
ENV MIKTEX_USERINSTALL=/miktex/.miktex/texmfs/install

RUN miktexsetup finish
RUN initexmf --set-config-value [MPM]AutoInstall=1

# Update miktex database
# Run multiple times to avoid MikTex error
RUN mpm --admin --update && mpm --update && mpm --admin --update && mpm --update

WORKDIR /script

# Build latex file
# Duplicated to avoid bug with citations not working
# See https://stackoverflow.com/questions/61096400/latex-miktex-undefined-citations
RUN echo "pdflatex -synctex=1 -interaction=nonstopmode --enable-write18 --jobname=thesis main \
    && bibtex thesis.aux \
    && pdflatex -synctex=1 -interaction=nonstopmode --enable-write18 --jobname=thesis main \
    && pdflatex -synctex=1 -interaction=nonstopmode --enable-write18 --jobname=thesis main" >> compile-latex.sh
RUN chmod +x compile-latex.sh

WORKDIR /output

ENTRYPOINT ["/bin/bash", "/script/compile-latex.sh"]