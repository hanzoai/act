# github.com/hanzoai/act — Hanzo's GitHub-Actions-compatible runner job image.
#
# When a .github/workflow says `runs-on: ubuntu-latest` (or hanzo-build-linux-amd64),
# the git-runner (act_runner) spins THIS image up as the job container. It replaces
# the third-party catthehacker/ubuntu:act-* images with a Hanzo-owned, Hanzo-registry
# artifact carrying the toolchain our workflows actually use. Extend as needed —
# this is ours to grow.
FROM ghcr.io/hanzoai/ubuntu:24.04
LABEL org.opencontainers.image.title="hanzo-runner-ubuntu" \
      org.opencontainers.image.source="https://github.com/hanzoai/act" \
      org.opencontainers.image.description="Hanzo Git Actions job runtime (GH-Actions ubuntu-compatible)"
ENV DEBIAN_FRONTEND=noninteractive LANG=C.UTF-8 ACT=true IMAGE_OS=ubuntu24 RUNNER_TOOL_CACHE=/opt/hostedtoolcache AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache
# Core GH-runner-equivalent toolchain: build tools, git, docker CLI+buildx, node, python, go, common utils.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg lsb-release software-properties-common \
      build-essential gcc g++ make pkg-config \
      git git-lfs jq unzip zip xz-utils rsync openssh-client sudo tzdata locales \
      python3 python3-pip python3-venv \
    && update-ca-certificates \
    # node 22 (nodesource)
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && apt-get install -y --no-install-recommends nodejs \
    # docker CLI + buildx (dind is provided by the runner pod's docker service)
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo $VERSION_CODENAME) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin \
    && mkdir -p /opt/hostedtoolcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
# Go 1.26.4 (matches our repos' go-version) into the tool cache + PATH.
RUN ARCH=$(dpkg --print-architecture) && case "$ARCH" in amd64) GOARCH=amd64;; arm64) GOARCH=arm64;; esac \
    && curl -fsSL "https://go.dev/dl/go1.26.4.linux-${GOARCH}.tar.gz" | tar -C /usr/local -xz \
    && ln -sf /usr/local/go/bin/go /usr/local/bin/go && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt
ENV PATH=/usr/local/go/bin:/opt/hostedtoolcache:$PATH
CMD ["/bin/bash"]
