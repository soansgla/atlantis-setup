FROM ghcr.io/runatlantis/atlantis:v0.19.1

WORKDIR /home/atlantis/
# hadolint ignore=DL4006,SC2155,DL4005,DL3018
RUN rm -f /bin/sh && ln -s /bin/bash /bin/sh && \
    apk add --no-cache \
        groff \
        jq \
        make \
        py3-pip=20.3.4-r1 && \
    apk --update --no-cache add \
        ca-certificates \
        curl \
        git \
        jq \
        libc6-compat \
        nodejs \
        npm \
        openssh-client \
        openssl \
        tar \
        unzip \
        uuidgen \
        zip &&\
    pip install --no-cache-dir awscli==1.21.2 && \
    curl -s -Lo /usr/local/bin/terragrunt https://github.com/gruntwork-io/terragrunt/releases/download/v0.36.3/terragrunt_linux_amd64 && \
    chmod +x /usr/local/bin/terragrunt && \
    curl -s -L https://github.com/infracost/infracost/releases/download/v0.10.2/infracost-linux-amd64.tar.gz | tar xz -C /tmp && \
    mv /tmp/infracost-linux-amd64 /usr/bin/infracost && \
    mkdir /atlantis && \
    chown -R atlantis: /atlantis

# hadolint ignore=DL3022
COPY --from=golang:1.18-alpine /usr/local/go/ /usr/local/go/
ENV PATH="/usr/local/go/bin:${PATH}"

USER atlantis
ENV ATLANTIS_DATA_DIR=/atlantis
ENV TF_PLUGIN_CACHE_DIR=/atlantis/plugin-cache
ENV ENVIRONMENT=dev
ENV ATLANTIS_DEFAULT_TF_VERSION=1.1.4
ENV ATLANTIS_GH_USER=<github_user>
ENV ATLANTIS_GH_TOKEN=<github_token>
ENV ATLANTIS_REPO_ALLOWLIST=github.com/<orgname>/*
ENV ATLANTIS_REPO_CONFIG=/home/atlantis/repos.yaml
ENV ATLANTIS_WRITE_GIT_CREDS=1
ENV ATLANTIS_LOG_LEVEL=debug
ENV ATLANTIS_AUTOMERGE=true
ENV INFRACOST_API_KEY=<API KEY>
COPY files/ /home/atlantis/
