ARG BASE_IMAGE=jupyterhub/k8s-hub
FROM $BASE_IMAGE

USER root
RUN pip3 install jupyter-server-proxy==4.0.0 kubernetes==26.1.0

USER ${NB_USER}