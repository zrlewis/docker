# docker

docker files for analysis

## Author: Zack Lewis

zack.lewis@alleninstitute.org


## Helpful commands

### Building

Building docker images on an ARM Mac is a little challenging.

Make sure to specify platform

```
docker build -f seurat_v5.Dockerfile --platform linux/amd64 -t zrlewis/seurat_v5:0.0.4 .
```

### Running

```
docker run --rm \
  --platform linux/x86_64 \
  -p 8787:8787 \
  -e PASSWORD=PASSWORD \
  -e DISABLE_AUTH=true \
  --mount type=bind,src="$(pwd)",target=/src \
  1b880222dc75
```

- Running jupyter

```
docker run --rm \
  --platform linux/x86_64 \
  -p 8888:8888 \
  -e PASSWORD=PASSWORD \
  -e DISABLE_AUTH=true \
  --mount type=bind,src="$(pwd)",target=/src \
  85604488034c
```

  - At the page requesting a password, enter the token from the terminal and a password, e.g., `PASSWORD`


### Stopping

```
docker stop $(docker ps -q)
```

### Pushing

```
docker push zrlewis/seurat_v5:0.0.4
```

### Converting to `singularity` `.sif` file

```
# log into HPC 
ssh hpc-login

# start an interactive session
srun -c 6 --mem=60G -t 2:00:00 -p celltypes --pty bash 

# make a directory or navigate to a directory for your `sif`
mkdir -p ./singularity && cd $_

# pull
singularity pull docker://zrlewis/seurat_v5:0.0.4
```

## Performing a multi-stage build

```
docker build -f r_system_essentials.Dockerfile --platform linux/amd64 -t zrlewis/r_system_essentials:0.1 .
docker push zrlewis/r_system_essentials:0.1
docker build -f seurat_multi_build.Dockerfile --platform linux/amd64 -t zrlewis/seurat_v5:0.0.10 .
docker push zrlewis/seurat_v5:0.0.10
```


## SSH Tunnel into a notebook

To tunnel into a notebook you need to start an interactive session or sbatch script and then `ssh` into the node it is running on.

```
# start an interactive session
tmux
srun -c 16 --gres=gpu:1 --mem=180G -t 8:00:00 -p celltypes --pty bash

# cd to your working directory.

# this should work, but having trouble setting password:
# singularity exec singularity/tclust_jupyter_0.1.sif jupyter lab --no-browser --ip 0.0.0.0 --port 9876 

# instead, start the image in shell and set up the config
singularity shell singularity/tclust_jupyter_0.1.sif 
jupyter lab --generate-config
jupyter lab password
# enter a password
# then start the notebook
# generating a config and password may no longer be necessary after the first time
jupyter lab --no-browser --ip 0.0.0.0 --port 9876

# in a separate terminal window, locally (not on the HPC)
ssh -NL 9876:<node>:9876 zack.lewis@hpc-login # where <node> is the node you are running singularity on
```