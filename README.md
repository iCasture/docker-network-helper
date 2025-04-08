# [Network Helper Docker Image](https://github.com/iCasture/docker-network-helper)

该仓库用于构建并发布 Network Helper 镜像，支持三种不同的发行版：

- Alpine (`alpine:3.21`)

- Debian (`debian:bookworm`)

- Debian-slim (`debian:bookworm-slim`)

支持以下平台：

- `amd64`

- `i386`

- `arm32v7`

- `arm64v8`

- `mips64le`（仅 Debian 镜像；Alpine 官方镜像不支持 `mips64le`）

- `riscv64`（仅 Alpine 镜像；Debian 官方镜像在 `bookworm` 下不支持 `riscv64`）

这些镜像均预装了常用网络工具，例如：

- `bash`

- `curl`

- `ping` (`iputils-ping`)

- `netstat`（`net-tools`）

- `tcpdump`

- `dig` / `nslookup`（`bind-tools` 或 `dnsutils`）

- `procps`（用于监控）

- `coreutils`（Alpine 环境下）

## 1. Tag

格式为：

```text
git-<commit-hash>-<variant>
```

- `debian`, `bookworm`, `latest-debian`, `latest-bookworm`, `latest`

- `git-xxxxxxx-debian`, `git-xxxxxxx-bookworm`

- `debian-slim`, `bookworm-slim`, `latest-debian-slim`, `latest-bookworm-slim`

- `git-xxxxxxx-debian-slim`, `git-xxxxxxx-bookworm-slim`

- `alpine`, `alpine3.21`, `latest-alpine`, `latest-alpine3.21`

- `git-xxxxxxx-alpine`, `git-xxxxxxx-alpine3.21`

## 2. 镜像构建

镜像通过 GitHub Actions 自动构建并推送至 GitHub Container Registry (ghcr.io) 和 Docker Hub (docker.io)。

注意：

1. 需要在 Repository -> Settings -> Secrets and variables -> Actions -> Repository secrets 中，设置好以下几个密钥：

    - `DOCKERHUB_USERNAME`（注意用户名需要全小写）

    - `DOCKERHUB_TOKEN`

    GitHub 相关的密钥无需手工配置。

2. 如果 Docker Hub 上的仓库不存在，GitHub Actions 默认建立的仓库可能是「私有 (Private)」的（取决于 Docker Hub 账号的 Default repository privacy 设置）。如果你是免费账号，那么只能建立一个私有仓库，超出数量的私有仓库会被锁定，造成推送失败。

    可以事先建立好「公开 (Public)」仓库来解决（或更改 Docker Hub 账号的 Default repository privacy 设置）。

## 3. 使用示例

下面是一个 `compose.yml` 示例配置：

```yaml
services:
  network-helper:
    image: ghcr.io/icasture/network-helper:git-abcdef12-alpine3.21
    container_name: network-helper
    ports:  # Optional
      - '9001:9001'
    networks:
      - global-network-helper-net

networks:
  global-network-helper-net:
    name: global-network-helper-net
    driver: bridge
```
