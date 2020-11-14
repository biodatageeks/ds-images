# images

## How to run the image
```
export TAG=''
docker run --rm -it -p 8889:8888 \
-e HOME=/tmp/jovyan \
biodatageeks/ds-notebook:$TAG \
jupyter-lab --ip='*' --NotebookApp.token='' --NotebookApp.password=''
```