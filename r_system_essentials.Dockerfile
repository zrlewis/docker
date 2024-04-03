FROM --platform=linux/amd64 rocker/tidyverse:4.3.2
LABEL org.opencontainers.image.authors="zack.lewis@alleninstitute.org"

# Set global R options
RUN echo "options(repos = 'https://cloud.r-project.org')" > $(R --no-echo --no-save -e "cat(Sys.getenv('R_HOME'))")/etc/Rprofile.site
ENV RETICULATE_MINICONDA_ENABLED=TRUE
ENV DEFAULT_USER=rstudio
ENV PANDOC_VERSION=default
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
