# Docker file for Seurat v5.0.1

# docker build -f seurat_v5.Dockerfile --platform linux/amd64 -t zrlewis/seurat_v5:0.0.1 .
   
# https://github.com/satijalab/seurat-docker/blob/master/latest/Dockerfile
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.3.2.Dockerfile

FROM --platform=linux/amd64 rocker/tidyverse:4.3.2
#LABEL org.opencontainers.image.authors="zack.lewis@alleninstitute.org"

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=TRUE
#ENV DEFAULT_USER=rstudio
#ENV PANDOC_VERSION=default
ENV PATH=/usr/lib/rstudio-server/bin:$PATH

# Install Seurat's system dependencies
RUN apt-get --allow-insecure-repositories update
#RUN apt-get install -y --no-install-recommends --allow-unauthenticated \
RUN apt-get install -y  \
    apt-transport-https \
    build-essential \
    git \
    libboost-all-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libhdf5-dev \
    libcurl4-openssl-dev \
    libfftw3-dev \
    libfontconfig1-dev \
    libgeos-dev \
    libgit2-dev \
    libglpk-dev \
    libgsl-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libssl-dev \
    libtiff5-dev \
    libxml2-dev \
    libzmq3-dev \
    openjdk-8-jdk \
    pip \
    python3-dev \
    python3-pip \
    wget \
    pkg-config 
    
#RUN apt-get install -y llvm-10*
RUN wget -O - https://apt.llvm.org/llvm.sh

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
RUN /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    echo "export PATH=/opt/conda/bin:$PATH" > /etc/profile.d/conda.sh
ENV PATH /opt/conda/bin:$PATH

#RUN conda init bash
#RUN conda create -n scvi python=3.9
#RUN conda activate scvi 
#RUN conda install -c conda-forge r-base r-essentials r-reticulate
#RUN conda install scvi-tools -c conda-forge
#RUN conda install anndata -c conda-forge

# Anndata
RUN echo "pip install --no-cache-dir --upgrade pip"
RUN echo "pip3 install anndata==0.8.0 numpy"
RUN R -e 'install.packages("anndata", update=TRUE)'

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

RUN install2.r -e -s \
	BiocManager \
    clustree \
	dplyr \
    ggplot2 \ 
	gplots \
	Hmisc \
	latticeExtra \
	scales \
	RANN \
	RColorBrewer \
    Rcpp \
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

# installing devtools
RUN R -e "install.packages('devtools', repos='http://cran.rstudio.com/', type='source', clean = TRUE, Ncpus = 2)"
#RUN apt-get -y install git pandoc make libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev libxml2-dev libgit2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev
#RUN apt-get -y build-dep libcurl4-gnutls-dev
#RUN apt-get -y install libcurl4-gnutls-dev

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
RUN R --no-echo --no-restore --no-save -e "remotes::install_github('AllenInstitute/scrattch.bigcat')"

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
RUN R --no-restore --no-save -e  "devtools::install_github('satijalab/seurat-wrappers', 'seurat5', quiet = TRUE)"

# Install LISI
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/immunogenomics/LISI/archive/refs/tags/v1.0.tar.gz')"

# Install scCustomize
RUN R --no-restore --no-save -e "BiocManager::install(c('ComplexHeatmap', 'dittoSeq', 'DropletUtils', 'Nebulosa'))"
RUN R --no-restore --no-save -e  "devtools::install_github('samuel-marsh/scCustomize', quiet = TRUE)"

## Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
RUN strip /usr/local/lib/R/site-library/*/libs/*.so

EXPOSE 8787

CMD ["/init"]

# To do:

# Install conda 
# conda install -c conda-forge r-base r-essentials r-reticulate
# Install scvi-tools (conda) or pip install scvi-tools
# https://docs.scvi-tools.org/en/stable/installation.html

# for SoupX:
# install DropletUtils
# install SoupX

# for Seurat doublet finder
# install DoubletFinder