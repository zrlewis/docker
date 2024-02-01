FROM --platform=linux/amd64 zrlewis/seurat_v5:0.0.4

# Force to use https for apt-get
RUN echo "deb https://deb.debian.org/debian/ stable main" > /etc/apt/sources.list

RUN sudo cp /etc/apt/sources.list /etc/apt/sources.list~
RUN sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
#RUN sudo apt-get update

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=TRUE 

# Anndata
RUN apt-get install -y apt-transport-https
RUN sudo apt-get clean
RUN apt-get --allow-insecure-repositories update
RUN apt-get --allow-unauthenticated install -y wget python3-dev python3-pip pip
RUN echo "pip install --no-cache-dir --upgrade pip"
RUN echo "pip3 install anndata==0.8.0 numpy"
RUN R -e 'install.packages("anndata", update=TRUE)'

# https://unix.stackexchange.com/questions/755552/problem-with-apt-public-keys-in-docker-image-building
RUN wget http://ftp.us.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.3+deb12u1_all.deb
RUN sudo dpkg -i debian-archive-keyring_2023.3+deb12u1_all.deb

# devtools package
RUN wget https://github.com/jgm/pandoc/releases/download/3.1.11.1/pandoc-3.1.11.1-1-amd64.deb
RUN sudo dpkg -i pandoc-3.1.11.1-1-amd64.deb
#RUN apt-get -y install make libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev libxml2-dev libgit2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev
#RUN apt-get -y build-dep libcurl4-gnutls-dev
#RUN apt-get -y install libcurl4-gnutls-dev
RUN R --no-restore --no-save -e "install.packages('https://cran.r-project.org/bin/macosx/big-sur-x86_64/contrib/4.3/devtools_2.4.5.tgz')"

# Install SeuratWrappers
RUN R --no-restore --no-save -e  "remotes::install_github('satijalab/seurat-wrappers', 'seurat5', quiet = TRUE)"

# Install conda 

RUN apt-get update 

RUN apt-get install -y wget 

RUN apt-get install -y bzip2 

RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.09-0-Linux-x86_64.sh
RUN sudo bash Anaconda3-2023.09-0-Linux-x86_64.sh -b -p ~/opt/anaconda3
RUN rm Anaconda3-2023.09-0-Linux-x86_64.sh

ENV PATH /opt/conda/bin:$PATH
ENV PATH /opt/anaconda3/bin:$PATH
RUN echo 'RETICULATE_PYTHON = "/opt/anaconda3/bin"' > .Renviron

#RUN conda update conda
#RUN conda update anaconda
#RUN conda update --all
#RUN conda activate scvi-env
#RUN conda install -c conda-forge r-base r-essentials r-reticulate scvi-tools


#RUN conda config --add channels conda-forge
#RUN conda create -n scvi-env python=3.9 r-base r-essentials r-reticulate scvi-tools
#RUN echo "conda activate scvi-env" > ~/.bashrc
#ENV PATH /opt/conda/envs/scvi-env/bin:$PATH
#RUN echo 'RETICULATE_PYTHON = "/opt/conda/bin"' > .Renviron

# Install scvi-tools (conda) or pip install scvi-tools
# https://docs.scvi-tools.org/en/stable/installation.html
# Install harmony https://github.com/immunogenomics/harmony or https://hub.docker.com/r/jzl010/harmony/tags

# Harmony
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('immunogenomics/harmony')"

# Scvi

EXPOSE 8787


CMD ["/init"]

## Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
RUN strip /usr/local/lib/R/site-library/*/libs/*.so