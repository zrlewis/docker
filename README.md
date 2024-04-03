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
