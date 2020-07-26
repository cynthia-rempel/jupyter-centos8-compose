ARG ROOT_CONTAINER=centos:centos8
ARG BASE_CONTAINER=$ROOT_CONTAINER
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"
ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

# Fix DL4006
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install all OS dependencies for notebook server that starts but lacks all
# features (e.g., download as all possible file formats)
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial \
 && dnf -y update \
 && dnf -y install dejavu-sans-fonts \
    unixODBC \
    unixODBC-devel \
    gcc-gfortran \
    gcc \
    dvipng \
    make automake gcc gcc-c++ kernel-devel \
    emacs-nox \
    vim-minimal \
    git \
    inkscape \
    libSM \
    libXext-devel \
    libXrender \
    texlive-lm \
    nmap-ncat \
    python3-devel \
    texlive-xetex \
    texlive-collection-fontsrecommended \
    texlive-plain \
    tzdata \
    unzip \
    nano \
    python3-pytest \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    liberation-fonts \
 && dnf clean all \
 && rm -rf /var/cache/dnf/*
# jed package not in centos
# texlive-fonts-extra not in centos
# ffmpeg not in centos
# r-cran-rodbc not in centos

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    NB_USER=$NB_USER \
    NB_UID=$NB_UID \
    NB_GID=$NB_GID \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8 \
    JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION=1.4.1
ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$NB_USER \
    XDG_CACHE_HOME="/home/${NB_USER}/.cache/" \
    JULIA_DEPOT_PATH=/opt/julia \
    JULIA_PKGDIR=/opt/julia \
    JULIA_VERSION=1.4.1

# Copy a script that we will use to correct permissions after running certain commands
COPY files /
RUN chmod a+rx /usr/bin/fix-permissions

# Enable prompt color in the skeleton .bashrc before creating the default NB_USER
RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

# Create NB_USER wtih name jovyan user with UID=1000 and in the 'users' group
# and make sure these dirs are writable by the `users` group.
RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
    sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
    sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
    useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER:$NB_GID $CONDA_DIR && \
    chmod g+w /etc/passwd && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $NB_UID
WORKDIR $HOME
ARG PYTHON_VERSION=default

# Setup work directory for backward-compatibility
RUN mkdir /home/$NB_USER/work && \
    fix-permissions /home/$NB_USER

# Install conda as jovyan and check the md5 sum provided on the download site
ENV MINICONDA_VERSION=4.8.3 \
    MINICONDA_MD5=d63adf39f2c220950a063e0529d4ff74 \
    CONDA_VERSION=4.8.3

WORKDIR /tmp
RUN wget --quiet https://repo.continuum.io/miniconda/Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "${MINICONDA_MD5} *Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh" | md5sum -c - && \
    /bin/bash Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-py38_${MINICONDA_VERSION}-Linux-x86_64.sh && \
    echo "conda ${CONDA_VERSION}" >> $CONDA_DIR/conda-meta/pinned && \
    conda config --system --prepend channels conda-forge && \
    conda config --system --set auto_update_conda false && \
    conda config --system --set show_channel_urls true && \
    conda config --system --set channel_priority flexible && \
    if [ ! $PYTHON_VERSION = 'default' ]; then conda install --yes python=$PYTHON_VERSION; fi && \
    conda list python | grep '^python ' | tr -s ' ' | cut -d '.' -f 1,2 | sed 's/$/.*/' >> $CONDA_DIR/conda-meta/pinned && \
    conda install --quiet --yes conda && \
    conda install --quiet --yes pip && \
    conda update --all --quiet --yes && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    conda clean --all -f -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    conda install --quiet --yes 'notebook=6.0.3' && \
    conda install --quiet --yes 'jupyterhub=1.1.0' && \
    conda install --quiet --yes 'jupyterlab=2.1.5' && \
    conda install --quiet --yes 'sympy=1.5.*' && \
    conda install --quiet --yes 'tini=0.18.0' && \
    conda install --quiet --yes 'beautifulsoup4=4.9.*' && \
    conda install --quiet --yes 'conda-forge::blas=*=openblas' && \
    conda install --quiet --yes 'bokeh=2.0.*' && \
    conda install --quiet --yes 'bottleneck=1.3.*' && \
    conda install --quiet --yes 'cloudpickle=1.4.*' && \
    conda install --quiet --yes 'cython=0.29.*' && \
    conda install --quiet --yes 'dask=2.15.*' && \
    conda install --quiet --yes 'dill=0.3.*' && \
    conda install --quiet --yes 'h5py=2.10.*' && \
    conda install --quiet --yes 'ipywidgets=7.5.*' && \
    conda install --quiet --yes 'ipympl=0.5.*' && \
    conda install --quiet --yes 'matplotlib-base=3.2.*' && \
    conda install --quiet --yes 'numba=0.48.*' && \
    conda install --quiet --yes 'numexpr=2.7.*' && \
    conda install --quiet --yes 'pandas=1.0.*' && \
    conda install --quiet --yes 'patsy=0.5.*' && \
    conda install --quiet --yes 'protobuf=3.11.*' && \
    conda install --quiet --yes 'pytables=3.6.*' && \
    conda install --quiet --yes 'scikit-image=0.16.*' && \
    conda install --quiet --yes 'scikit-learn=0.23.*' && \
    conda install --quiet --yes 'scipy=1.4.*' && \
    conda install --quiet --yes 'seaborn=0.10.*' && \
    conda install --quiet --yes 'sqlalchemy=1.3.*' && \
    conda install --quiet --yes 'statsmodels=0.11.*' && \
    conda install --quiet --yes 'vincent=0.4.*' && \
    conda install --quiet --yes 'widgetsnbextension=3.5.*' && \
    conda install --quiet --yes 'xlrd=1.2.*' && \
    conda install --quiet --yes 'r-base=3.6.3' && \
    conda install --quiet --yes 'r-caret=6.0*' && \
    conda install --quiet --yes 'r-crayon=1.3*' && \
    conda install --quiet --yes 'r-devtools=2.3*' && \
    conda install --quiet --yes 'r-forecast=8.12*' && \
    conda install --quiet --yes 'r-hexbin=1.28*' && \
    conda install --quiet --yes 'r-htmltools=0.4*' && \
    conda install --quiet --yes 'r-htmlwidgets=1.5*' && \
    conda install --quiet --yes 'r-irkernel=1.1*' && \
    conda install --quiet --yes 'r-nycflights13=1.0*' && \
    conda install --quiet --yes 'r-plyr=1.8*' && \
    conda install --quiet --yes 'r-randomforest=4.6*' && \
    conda install --quiet --yes 'r-rcurl=1.98*' && \
    conda install --quiet --yes 'r-reshape2=1.4*' && \
    conda install --quiet --yes 'r-rmarkdown=2.1*' && \
    conda install --quiet --yes 'r-rsqlite=2.2*' && \
    conda install --quiet --yes 'r-shiny=1.4*' && \
    conda install --quiet --yes 'r-tidyverse=1.3*' && \
    conda install --quiet --yes 'rpy2=3.1*' && \
    conda install --quiet --yes 'tensorflow==2.2.0' && \
    conda install --quiet --yes pytest && \
    conda install --quiet --yes docker-py && \
    conda install --quiet --yes tabulate && \
    conda install --quiet --yes recommonmark==0.5.0 && \
    conda install --quiet --yes requests && \
    conda install --quiet --yes sphinx>=1.6 && \
    conda install --quiet --yes transifex-client && \
    conda list tini | grep tini | tr -s ' ' | cut -d ' ' -f 1,2 >> $CONDA_DIR/conda-meta/pinned && \
    conda clean --all -f -y && \
    npm cache clean --force && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    rm -rf /home/$NB_USER/.cache/yarn

USER root

# Julia
RUN mkdir "/opt/julia-${JULIA_VERSION}" && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/$(echo "${JULIA_VERSION}" | cut -d. -f 1,2)"/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    echo "fd6d8cadaed678174c3caefb92207a3b0e8da9f926af6703fb4d1e4e4f50610a *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf "julia-${JULIA_VERSION}-linux-x86_64.tar.gz" -C "/opt/julia-${JULIA_VERSION}" --strip-components=1 && \
    rm "/tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz" && \
    ln -fs /opt/julia-*/bin/julia /usr/bin/julia && \
    mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir "${JULIA_PKGDIR}" && \
    chown "${NB_USER}" "${JULIA_PKGDIR}" && \
    fix-permissions "${JULIA_PKGDIR}" && \
    fix-permissions "/tests/"

USER $NB_UID

# Jupyter notebook
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
    jupyter labextension install @jupyter-widgets/jupyterlab-manager@^2.0.0 --no-build && \
    jupyter labextension install @bokeh/jupyter_bokeh@^2.0.0 --no-build && \
    jupyter labextension install jupyter-matplotlib@^0.7.2 --no-build && \
    jupyter lab build --dev-build=False --minimize=False -y && \
    jupyter lab clean -y && \
    npm cache clean --force && \
    jupyter notebook --generate-config && \
    rm -rf $CONDA_DIR/share/jupyter/lab/staging && \
    rm -rf "/home/${NB_USER}/.node-gyp" && \
    rm -rf /home/$NB_USER/.cache/yarn && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    cd /tmp && \
    git clone https://github.com/PAIR-code/facets.git && \
    jupyter nbextension install facets/facets-dist/ --sys-prefix && \
    rm -rf /tmp/facets && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}" && \
    MPLBACKEND=Agg python -c "import matplotlib.pyplot" && \
    fix-permissions "/home/${NB_USER}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


EXPOSE 8888

# Configure container startup
ENTRYPOINT ["tini", "-g", "--"]
CMD ["start-notebook.sh"]

# Fix permissions on /etc/jupyter as root
USER root
RUN fix-permissions /etc/jupyter/

# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID

WORKDIR $HOME

# References:
#  https://linuxhint.com/install_jupyter_notebook_centos8/
