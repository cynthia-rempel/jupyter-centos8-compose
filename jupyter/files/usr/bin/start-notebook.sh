#!/bin/bash
# https://github.com/jupyter/docker-stacks/blob/master/base-notebook/start-notebook.sh
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e

wrapper=""
if [[ "${RESTARTABLE}" == "yes" ]]; then
    wrapper="run-one-constantly"
fi

if [[ ! -z "${JUPYTERHUB_API_TOKEN}" ]]; then
    # launched by JupyterHub, use single-user entrypoint
    exec /usr/bin/start-singleuser.sh "$@"
elif [[ ! -z "${JUPYTER_ENABLE_LAB}" ]]; then
    . /usr/bin/start.sh $wrapper jupyter lab "$@"
else
    . /usr/bin/start.sh $wrapper jupyter notebook "$@"
fi


