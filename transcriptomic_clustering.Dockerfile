FROM python:3.8-bullseye

#MAINTAINER Nelson Johansen nelson.johansen@alleninstitute.org
RUN export GITHUB_PAT=1000

##
RUN pip install numpy pandas scipy>=1.7.0 six anndata==0.8.0 scanpy scikit-misc
RUN pip install psutil Welford Phenograph annoy networkx leidenalg==0.8.4 python-louvain click

##
wget https://github.com/AllenInstitute/transcriptomic_clustering/archive/refs/heads/hmba/dev.zip
unzip 


#RUN git clone https://github.com/AllenInstitute/transcriptomic_clustering.git
#RUN cd transcriptomic_clustering && git checkout hmba-dev
ADD transcriptomic_clustering-hmba-dev ./transcriptomic_clustering-hmba-dev
RUN pip install -e ./transcriptomic_clustering-hmba-dev

WORKDIR /jup

RUN pip install jupyter -U && pip install jupyterlab

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]

##
#ENTRYPOINT ["/bin/bash"]
