# [Network Helper Docker Image](https://github.com/iCasture/docker-network-helper)

该仓库用于构建并发布 Network Helper 镜像，支持三种不同的发行版：

- Alpine (`alpine:3.22`)

- Debian (`debian:trixie`)

- Debian-slim (`debian:trixie-slim`)

支持以下平台：

- `amd64`

- `i386`

- `arm32v7`

- `arm64v8`

- ~~`mips64le`~~（Alpine 官方镜像不支持 `mips64le`；Debian `trixie` 官方镜像也暂不支持 `mips64le`）

- `riscv64`

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

- `debian`, `trixie`, `latest-debian`, `latest-trixie`, `latest`

- `git-xxxxxxx-debian`, `git-xxxxxxx-trixie`

- `debian-slim`, `trixie-slim`, `latest-debian-slim`, `latest-trixie-slim`

- `git-xxxxxxx-debian-slim`, `git-xxxxxxx-trixie-slim`

- `alpine`, `alpine3.22`, `latest-alpine`, `latest-alpine3.22`

- `git-xxxxxxx-alpine`, `git-xxxxxxx-alpine3.22`

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
    image: ghcr.io/icasture/network-helper:git-abcdef12-alpine3.22
    container_name: network-helper
    ports:  # 可选, 用于将某些端口暴露给宿主机
      - '34567:5432'
    networks:
      - global-network-helper-net
      - global-postgres-vector-net

networks:
  global-network-helper-net:
    name: global-network-helper-net
    driver: bridge
  global-postgres-vector-net:
    external: true
```

通过上述配置，即可将 `network-helper` 容器加入 `global-network-helper-net` 和 `global-postgres-vector-net` (`external`) 网络中，其作用包括：

1. 无需额外配置即可访问同网络中未暴露的端口

    容器可以直接访问 `global-postgres-vector-net` 网络中其他容器未通过 `ports` 暴露的端口，无需在该容器或目标容器中额外设置端口映射。

    > `network-helper` 本身可作为网络调试容器，内置如 `curl`、`ping` 等基础工具，也可自行安装 `psql` 等客户端，用于测试服务连通性或排查网络策略。

    例如，通过上述配置，`network-helper` 可以直接访问 `global-postgres-vector-net` 网络中某个 PostgreSQL 容器的 `5432` 端口，无需在目标容器或本容器中添加额外配置（不需要上面的那条 `ports` 命令）。

2. 集中管理端口映射规则

    可选地通过 `ports` 指令将目标网络中某些端口映射至宿主机，避免在多个 `compose.yaml` 文件中分别配置，实现统一管理。例如，以下配置：

    ```yaml
    ports:  # 可选, 将某些端口暴露给宿主机
      - '34567:5432'
    ```

    表示将 `global-postgres-vector-net` 网络中容器开放的 `5432` 端口映射至宿主机的 `34567` 端口。

3. 实现跨 Compose 项目通信

    将多个 Compose 项目同时加入同一个网络（例如上面的 `global-network-helper-net` 网络），可以打破默认的网络隔离，实现跨服务、跨 Compose 的互联互通。
