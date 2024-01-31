# Docker file for Seurat v5.0.1
# By Zack Lewis zack.lewis@alleninstitute.org

# docker build -f seurat_v5.Dockerfile --platform linux/amd64 -t zrlewis/seurat_v5:0.0.1 .
   
# https://github.com/satijalab/seurat-docker/blob/master/latest/Dockerfile
# https://github.com/rocker-org/rocker-versioned2/blob/master/dockerfiles/rstudio_4.3.2.Dockerfile

FROM rocker/rstudio:4.3.2

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=FALSE

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
    V8

# devtools package
#RUN apt-get -y install git pandoc make libssl-dev libfreetype6-dev libfribidi-dev libharfbuzz-dev libfontconfig1-dev libxml2-dev libgit2-dev libcurl4-openssl-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev
#RUN apt-get -y build-dep libcurl4-gnutls-dev
#RUN apt-get -y install libcurl4-gnutls-dev

#RUN R --no-restore --no-save -e "install.packages('https://github.com/r-lib/devtools/archive/refs/tags/v2.4.5.tar.gz')"
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

#CMD [ "R" ]

EXPOSE 8787
#EXPOSE map[8787/tcp:{}]

CMD ["/init"]

## Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
RUN strip /usr/local/lib/R/site-library/*/libs/*.so