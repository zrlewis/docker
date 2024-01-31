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
  -e PASSWORD=12345 \
  -e DISABLE_AUTH=true \
  --mount type=bind,src="$(pwd)",target=/src \
  040195206a70

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