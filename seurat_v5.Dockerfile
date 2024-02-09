# Docker file for Seurat v5.0.1
# By Zack Lewis zack.lewis@alleninstitute.org

# docker build -f seurat_v5.Dockerfile --platform linux/amd64 -t zrlewis/seurat_v5:0.0.1 .
   
# https://github.com/satijalab/seurat-docker/blob/master/latest/Dockerfile
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.3.2.Dockerfile

FROM --platform=linux/amd64 rocker/tidyverse

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

# Install Seurat's system dependencies
RUN apt-get update
RUN apt-get install -y \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libpng-dev \
    libboost-all-dev \
    libxml2-dev \
    openjdk-8-jdk \
    python3-dev \
    python3-pip \
    wget \
    git \
    libfftw3-dev \
    libgsl-dev \
    pkg-config

#RUN apt-get install -y llvm-10*
RUN wget -O - https://apt.llvm.org/llvm.sh

#ENV DEFAULT_USER=rstudio
#ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

#RUN /rocker_scripts/install_rstudio.sh
#RUN /rocker_scripts/install_pandoc.sh


# Install system library for rgeos
RUN apt-get install -y libgeos-dev

# Install UMAP
RUN LLVM_CONFIG=/usr/lib/llvm-10/bin/llvm-config pip3 install llvmlite
RUN pip3 install numpy
RUN pip3 install umap-learn

# Install FIt-SNE
RUN git clone --branch v1.2.1 https://github.com/KlugerLab/FIt-SNE.git
RUN g++ -std=c++11 -O3 FIt-SNE/src/sptree.cpp FIt-SNE/src/tsne.cpp FIt-SNE/src/nbodyfft.cpp  -o bin/fast_tsne -pthread -lfftw3 -lm

# Install bioconductor dependencies & suggests
RUN R --no-echo --no-restore --no-save -e "install.packages('BiocManager')"
RUN R --no-echo --no-restore --no-save -e "BiocManager::install(c('multtest', 'S4Vectors', 'SummarizedExperiment', 'SingleCellExperiment', 'MAST', 'DESeq2', 'BiocGenerics', 'GenomicRanges', 'IRanges', 'rtracklayer', 'monocle', 'Biobase', 'limma', 'glmGamPoi'))"

# Install CRAN suggests
RUN R --no-echo --no-restore --no-save -e "install.packages(c('VGAM', 'R.utils', 'metap', 'Rfast2', 'ape', 'enrichR', 'mixtools'))"

# Install spatstat
RUN R --no-echo --no-restore --no-save -e "install.packages(c('spatstat.explore', 'spatstat.geom'))"

# Install hdf5r
RUN R --no-echo --no-restore --no-save -e "install.packages('hdf5r')"

# Install latest Matrix
RUN R --no-echo --no-restore --no-save -e "install.packages('Matrix')"

# Install rgeos
RUN R --no-echo --no-restore --no-save -e "install.packages('rgeos')"

RUN R --no-echo --no-restore --no-save -e "install.packages('https://cran.r-project.org/src/contrib/tidyverse_2.0.0.tar.gz')"

RUN install2.r -e -s \
	BiocManager \
	dplyr \
    ggplot2 \ 
	gplots \
	Hmisc \
	latticeExtra \
	scales \
	RANN \
	RColorBrewer \
    Rcpp \
	remotes \
	Rtsne \
    gridExtra \
    plotly \ 
    stringr \
    patchwork \ 
    cowplot \
    uwot \
    readr \
    tidyr \ 
    RcppArmadillo \
    V8

# devtools package
# maybe try this?
# https://github.com/hvalev/shiny-server-arm-docker/blob/master/Dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libzmq3-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    build-essential \
    libcurl4-openssl-dev \
    libxml2-dev \
    libssl-dev \
    libfontconfig1-dev \
    libgit2-dev && \
    rm -rf /var/lib/apt/lists/*

# installing devtools
RUN R -e "install.packages('devtools', repos='http://cran.rstudio.com/', type='source', clean = TRUE, Ncpus = 2)"
#RUN apt-get -y install git pandoc make libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev libxml2-dev libgit2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev
#RUN apt-get -y build-dep libcurl4-gnutls-dev
#RUN apt-get -y install libcurl4-gnutls-dev

#RUN R --no-restore --no-save -e "install.packages('https://cran.r-project.org/bin/macosx/big-sur-x86_64/contrib/4.3/devtools_2.4.5.tgz')"
#RUN R "library(devtools)" # check install

# tidyverse install not working. just install tibble
#RUN install2.r -e -s tidyverse
# could try installing from source https://github.com/tidyverse/tidyverse/archive/refs/tags/v2.0.0.tar.gz
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/tidyverse/tibble/archive/refs/tags/v3.2.1.tar.gz')"

# Install igraph from source. Seurat isn't able to install it, it seems
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/igraph/rigraph/archive/refs/tags/v1.6.0.tar.gz')"
# or perhaps this is the better way
# R CMD INSTALL https://github.com/igraph/rigraph/archive/refs/tags/v1.6.0.tar.gz

# Install leiden from source
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/TomKellyGenetics/leiden/archive/refs/tags/0.4.3.1.tar.gz')"

# Install remotes (fewer dependencies than devtools)
RUN R --no-echo --no-restore --no-save -e "install.packages('remotes')"

# Instal scrattch.hicat and dependencies
#RUN R --no-echo --no-restore --no-save -e "devtools::install_github('JinmiaoChenLab/Rphenograph')" 
# having trouble installing Rphenograph. Try using this forked version from source
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/i-cyto/Rphenograph/archive/refs/tags/Rphenograph_0.99.1.9003.tar.gz')"
#RUN R --no-echo --no-restore --no-save -e "remotes::install_github('AllenInstitute/scrattch.hicat')"
# dependencies for scrattch.hicat that could not be installed: devtools, qlcMatrix, WCGNA
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('AllenInstitute/scrattch.vis')"

# Install Seurat
RUN R --no-echo --no-restore --no-save -e "install.packages('Seurat')"

# Install SeuratDisk
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('mojaveazure/seurat-disk')"

# Install Scillus for heatmaps
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('xmc811/Scillus', ref = 'development')"

# Install presto for fast DE analysis
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('immunogenomics/presto')"

# Harmony
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('immunogenomics/harmony')"

# Install SeuratWrappers
RUN R --no-restore --no-save -e  "remotes::install_github('satijalab/seurat-wrappers', 'seurat5', quiet = TRUE)"

# Install LISI
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/immunogenomics/LISI/archive/refs/tags/v1.0.tar.gz')"

EXPOSE 8787

CMD ["/init"]

## Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
RUN strip /usr/local/lib/R/site-library/*/libs/*.so


# To do:

# Install SeuratWrappers
# Install conda 
# conda install -c conda-forge r-base r-essentials r-reticulate
# Install scvi-tools (conda) or pip install scvi-tools
# https://docs.scvi-tools.org/en/stable/installation.html
# Install harmony https://github.com/immunogenomics/harmony or https://hub.docker.com/r/jzl010/harmony/tags

# for SoupX:
# install DropletUtils
# install SoupX

# for Seurat doublet finder
# install DoubletFinder