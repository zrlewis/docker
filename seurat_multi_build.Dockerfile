FROM --platform=linux/amd64 zrlewis/r_system_essentials:0.1
LABEL org.opencontainers.image.authors="zack.lewis@alleninstitute.org"


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
	#BiocManager \
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
    reticulate \
    tidyr \ 
    RcppArmadillo \
    V8

# installing devtools
RUN R -e "install.packages('devtools', repos='http://cran.rstudio.com/', type='source', clean = TRUE, Ncpus = 2)"

# Install igraph from source. Seurat isn't able to install it, it seems
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/igraph/rigraph/archive/refs/tags/v1.6.0.tar.gz')"

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
RUN R --no-restore --no-save -e  "devtools::install_github('satijalab/seurat-wrappers', 'seurat5', quiet = TRUE)"

# Install LISI
RUN R --no-echo --no-restore --no-save -e "install.packages('https://github.com/immunogenomics/LISI/archive/refs/tags/v1.0.tar.gz')"

## Clean up
RUN rm -rf /var/lib/apt/lists/*
RUN rm -rf /tmp/downloaded_packages

## Strip binary installed libraries from RSPM
## https://github.com/rocker-org/rocker-versioned2/issues/340
RUN strip /usr/local/lib/R/site-library/*/libs/*.so