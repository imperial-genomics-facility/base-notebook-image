FROM ubuntu:16.04
MAINTAINER igf[at]imperial.ac.uk
LABEL maintainer="imperialgenomicsfacility"

ENV NB_USER vmuser
ENV NB_GROUP vmuser
ENV NB_UID 1000
USER root
WORKDIR /
RUN adduser --disabled-password \
      --gecos "Default user" \
      --uid ${NB_UID} \
      ${NB_USER} && \
    usermod -a -G $NB_GROUP $NB_USER && \
    apt-get -y update &&   \
    apt-get install --no-install-recommends -y \
      apt-utils \
      locales \
      wget \
      unzip \
      cmake \
      g++ \
      libxml2-dev \
      ca-certificates \
      zlib1g-dev \
      libfftw3-dev \
      build-essential && \
    locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    apt-get purge -y --auto-remove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV TINI_VERSION v0.18.0
RUN mkdir -p /tmp && \
    wget --quiet --no-check-certificate \
      -O /tmp/tini \
      https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini && \
    mv /tmp/tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini
USER $NB_USER
WORKDIR /home/$NB_USER
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} /home/$NB_USER && \
    chmod a+x /home/$NB_USER/entrypoint.sh && \
     rm -rf /tmp/*
USER ${NB_USER}
WORKDIR /home/$NB_USER
ENV TMPDIR=/home/$NB_USER/.tmp
RUN  mkdir -p ${TMPDIR} && \
     wget --quiet --no-check-certificate \
       -O /home/$NB_USER/Miniconda3-latest-Linux-x86_64.sh \
       https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     bash /home/$NB_USER/Miniconda3-latest-Linux-x86_64.sh -b
ENV PATH $PATH:/home/$NB_USER/miniconda3/bin/
RUN conda config --set safety_checks disabled && \
    conda env create -q -n notebook-env --file /home/$NB_USER/environment.yml && \
    echo ". /home/$NB_USER/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "source activate notebook-env" >> ~/.bashrc && \
    conda clean -a -y && \
    rm -rf /home/$NB_USER/.cache && \
    rm -rf /tmp/* && \
    rm -rf ${TMPDIR} && \
    mkdir -p ${TMPDIR} && \
    mkdir -p /home/$NB_USER/.cache && \
    mkdir -p /home/$NB_USER/.jupyter && \
    find miniconda3/ -type f -name *.pyc -exec rm -f {} \; && \
    rm -f Miniconda3-latest-Linux-x86_64.sh && \
    echo "c.NotebookApp.password = u'sha1:0e221c95f37a:f9e0f0df2c274287b168eaa378877327fdd39029'" > /home/$NB_USER/.jupyter/jupyter_notebook_config.py
EXPOSE 8888
ENTRYPOINT [ "/usr/local/bin/tini","--","/home/vmuser/entrypoint.sh" ]
CMD [ "notebook" ]
