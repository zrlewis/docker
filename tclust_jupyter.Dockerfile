FROM njjai/tclust:0.1

WORKDIR /jup

RUN pip install --upgrade pip
RUN apt-get install -y python3.9
RUN pip install jupyter -U && pip install jupyterlab
RUN pip install scvi-tools && pip install scib-metrics

EXPOSE 8888

ENTRYPOINT ["jupyter", "lab","--ip=0.0.0.0","--allow-root"]

##
#ENTRYPOINT ["/bin/bash"]
