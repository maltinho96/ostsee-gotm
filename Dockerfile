# Ostsee-GOTM: reproduzierbare Umgebung für GOTM + FABM + ERGOM
# Bauen:   docker build -t ghcr.io/maltinho96/ostsee-gotm:v0.1 .
# Starten: ./run.sh

FROM ubuntu:24.04

# Verknüpft das Image mit dem GitHub-Repo
LABEL org.opencontainers.image.source=https://github.com/maltinho96/ostsee-gotm

# Feste GOTM-Version (Tag oder Commit-Hash) -> FAIR / reproduzierbar
# Verfügbare Tags: git ls-remote --tags https://github.com/gotm-model/code.git
ARG GOTM_REF=master

ENV DEBIAN_FRONTEND=noninteractive

# 1) Compiler, NetCDF, Build-Tools, Python
RUN apt-get update && apt-get install -y --no-install-recommends \
        git ca-certificates cmake make gfortran \
        libnetcdf-dev libnetcdff-dev \
        python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*

# 2) GOTM inkl. FABM (Submodul, enthält ERGOM unter iow/ergom) bauen
RUN git clone --recursive https://github.com/gotm-model/code.git /opt/gotm-src \
    && cd /opt/gotm-src \
    && git checkout ${GOTM_REF} \
    && git submodule update --init --recursive \
    && cmake -S /opt/gotm-src -B /opt/gotm-build \
         -DGOTM_USE_FABM=ON \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=/opt/gotm \
    && cmake --build /opt/gotm-build -j"$(nproc)" \
    && cmake --install /opt/gotm-build \
    && git -C /opt/gotm-src rev-parse HEAD > /opt/gotm/GOTM_COMMIT.txt \
    && rm -rf /opt/gotm-build

# 3) Python-Umgebung für Auswertung und Plots
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt

ENV PATH="/opt/gotm/bin:/opt/venv/bin:${PATH}"

WORKDIR /work
CMD ["bash"]
