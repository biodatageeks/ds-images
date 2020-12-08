ARG BASE_IMAGE=jupyterhub/k8s-hub
FROM $BASE_IMAGE

USER root
RUN pip3 install jupyter-server-proxy==1.5.0

USER ${NB_USER}