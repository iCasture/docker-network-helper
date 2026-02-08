# [Network Helper Docker Image](https://github.com/iCasture/docker-network-helper)

该仓库用于构建并发布 Network Helper 镜像，支持四种不同的发行版：

- Alpine (`alpine:3.23`)

- Debian (`debian:trixie`)

- Debian-slim (`debian:trixie-slim`)

- Ubuntu (`ubuntu:24.04`)

支持以下平台：

- `amd64`

- `arm32v7`

- `arm64v8`

- `riscv64`

- `i386` (仅 Alpine / Debian 版本支持，Ubuntu 官方镜像不支持 `i386`)

- ~~`mips64le`~~ ( Alpine / Ubuntu 官方镜像不支持 `mips64le`；Debian 从 `trixie` 起也不支持)

## 1. 镜像版本

### 1.1. Basic 版本

包含最常用的网络调试工具，镜像体积最小，启动速度最快：

**基础系统工具：**

- `bash` - Shell 环境

- `ca-certificates` - SSL / TLS 证书支持

- `coreutils` & `busybox-extras` (Alpine) - 基础工具集

**核心网络工具：**

- `curl` - HTTP 客户端

- `dig` / `nslookup` (`bind-tools` 或 `dnsutils`) - 基础 DNS 查询

- `nc` (`netcat-openbsd`) - 网络调试瑞士军刀

- `netstat` (`net-tools`) - 网络连接查看

- `ping` (`iputils-ping`) - 连通性测试

- `telnet` - 端口连通性测试 (仅 Debian；Alpine 下包含在 busybox-extras 中)

- `wget` - 下载工具

### 1.2. Standard 版本（默认）

在 Basic 版本基础上，增加高级网络诊断和性能测试工具：

**高级网络工具：**

- `ethtool` - 网络接口配置和诊断

- `iperf3` - 网络性能测试

- `iproute2` - 现代网络工具集 (`ip`, `ss`, `tc` 等)

- `lsof` - 查看进程打开的文件和网络连接

- `openssl` - SSL / TLS 连接测试工具

- `tcpdump` - 网络包捕获

**系统工具：**

- `jq` - JSON 处理工具

- `procps` - 系统监控

### 1.3. Advanced 版本

在 Standard 版本基础上，增加安全分析和高级监控工具：

**安全和分析工具：**

- `dnsx` - 快速多用途 DNS 工具包

- `knot` - 现代 DNS 工具集，提供 `kdig`（`dig` 的增强替代）、`khost`、`knsupdate` 等工具

- `mitmproxy` - HTTP / HTTPS 代理工具，用于拦截、检查和修改 Web 流量 (仅支持 `amd64` 和 `arm64v8` 的 Debian / Ubuntu 镜像，其它镜像下为占位符)

- `nmap` - 端口扫描和网络发现

- `socat` - 网络数据转发工具

- `tshark` - Wireshark 命令行工具，深度包分析

**监控和诊断工具：**

- `iftop` - 网络流量监控

- `mtr` - 网络诊断工具 (`traceroute` + `ping` 组合)

- `traceroute` - 路由跟踪

- `whois` - 域名信息查询工具

**系统和管理工具：**

- `htop` - 增强版系统监控

- `openssh-client` - SSH 客户端

- `rsync` - 文件同步工具

- `vim` - 文本编辑器

### 1.4. 版本选择指导

| 使用场景      | 推荐版本  | 说明                   |
|--------------|----------|----------------------|
| 基础连通性测试 | Basic    | 最小体积，快速启动       |
| 网络性能调优   | Standard | 包含性能测试工具        |
| 安全审计分析   | Advanced | 完整的安全工具集        |
| CI/CD 环境    | Basic    | 减少构建时间和存储空间   |
| 生产环境调试   | Standard  | 平衡功能和体积         |
| 渗透测试      | Advanced  | 专业安全工具           |

## 2. 镜像标签

### 2.1. 标签格式

标签格式为：

```text
git-<commit-hash>-<variant>[-<target>]
```

其中：

- `<variant>`: `alpine`, `alpine3.23`, `debian`, `trixie`, `debian-slim`, `trixie-slim`, `ubuntu`, `noble`

- `<target>`: `basic`, `standard`（默认，可省略）, `advanced`

### 2.2. Basic 版本标签

**Alpine Basic:**

- `alpine-basic`, `alpine3.23-basic`, `latest-alpine-basic`, `latest-alpine3.23-basic`

- `git-xxxxxxx-alpine-basic`, `git-xxxxxxx-alpine3.23-basic`

**Debian Basic:**

- `debian-basic`, `trixie-basic`, `latest-debian-basic`, `latest-trixie-basic`

- `git-xxxxxxx-debian-basic`, `git-xxxxxxx-trixie-basic`

**Debian-slim Basic:**

- `debian-slim-basic`, `trixie-slim-basic`, `latest-debian-slim-basic`, `latest-trixie-slim-basic`

- `git-xxxxxxx-debian-slim-basic`, `git-xxxxxxx-trixie-slim-basic`

**Ubuntu Basic:**

- `ubuntu-basic`, `noble-basic`, `latest-ubuntu-basic`, `latest-noble-basic`

- `git-xxxxxxx-ubuntu-basic`, `git-xxxxxxx-noble-basic`

### 2.3. Standard 版本标签（默认）

**Alpine Standard:**

- `alpine`, `alpine3.23`, `latest-alpine`, `latest-alpine3.23`

- `alpine-standard`, `alpine3.23-standard`, `latest-alpine-standard`, `latest-alpine3.23-standard`

- `git-xxxxxxx-alpine`, `git-xxxxxxx-alpine3.23`

- `git-xxxxxxx-alpine-standard`, `git-xxxxxxx-alpine3.23-standard`

**Debian Standard:**

- `debian`, `trixie`, `latest-debian`, `latest-trixie`

- `debian-standard`, `trixie-standard`, `latest-debian-standard`, `latest-trixie-standard`

- `git-xxxxxxx-debian`, `git-xxxxxxx-trixie`

- `git-xxxxxxx-debian-standard`, `git-xxxxxxx-trixie-standard`

**Debian-slim Standard:**

- `debian-slim`, `trixie-slim`, `latest-debian-slim`, `latest-trixie-slim`

- `debian-slim-standard`, `trixie-slim-standard`, `latest-debian-slim-standard`, `latest-trixie-slim-standard`

- `git-xxxxxxx-debian-slim`, `git-xxxxxxx-trixie-slim`

- `git-xxxxxxx-debian-slim-standard`, `git-xxxxxxx-trixie-slim-standard`

**Ubuntu Standard:**

- `ubuntu`, `noble`, `latest-ubuntu`, `latest-noble`, `latest`

- `ubuntu-standard`, `noble-standard`, `latest-ubuntu-standard`, `latest-noble-standard`

- `git-xxxxxxx-ubuntu`, `git-xxxxxxx-noble`

- `git-xxxxxxx-ubuntu-standard`, `git-xxxxxxx-noble-standard`

### 2.4. Advanced 版本标签

**Alpine Advanced:**

- `alpine-advanced`, `alpine3.23-advanced`, `latest-alpine-advanced`, `latest-alpine3.23-advanced`

- `git-xxxxxxx-alpine-advanced`, `git-xxxxxxx-alpine3.23-advanced`

**Debian Advanced:**

- `debian-advanced`, `trixie-advanced`, `latest-debian-advanced`, `latest-trixie-advanced`

- `git-xxxxxxx-debian-advanced`, `git-xxxxxxx-trixie-advanced`

**Debian-slim Advanced:**

- `debian-slim-advanced`, `trixie-slim-advanced`, `latest-debian-slim-advanced`, `latest-trixie-slim-advanced`

- `git-xxxxxxx-debian-slim-advanced`, `git-xxxxxxx-trixie-slim-advanced`

**Ubuntu Advanced:**

- `ubuntu-advanced`, `noble-advanced`, `latest-ubuntu-advanced`, `latest-noble-advanced`

- `git-xxxxxxx-ubuntu-advanced`, `git-xxxxxxx-noble-advanced`

## 3. 镜像构建

镜像通过 GitHub Actions 自动构建并推送至 GitHub Container Registry (ghcr.io) 和 Docker Hub (docker.io)。支持从两个注册表拉取镜像：

```bash
# GitHub Container Registry
docker pull ghcr.io/icasture/network-helper:noble  # Standard version (default)
docker pull ghcr.io/icasture/network-helper:noble-standard  # Explicit standard

# Docker Hub
docker pull icasture/network-helper:noble  # Standard version (default)
docker pull icasture/network-helper:noble-standard  # Explicit standard
```

注意：

1. 需要在 Repository -> Settings -> Secrets and variables -> Actions -> Repository secrets 中，设置好以下几个密钥：

    - `DOCKERHUB_USERNAME`（注意用户名需要全小写）

    - `DOCKERHUB_TOKEN`

    GitHub 相关的密钥无需手工配置。

2. 如果 Docker Hub 上的仓库不存在，GitHub Actions 默认建立的仓库可能是「私有 (Private)」的（取决于 Docker Hub 账号的 Default repository privacy 设置）。如果你是免费账号，那么只能建立一个私有仓库，超出数量的私有仓库会被锁定，造成推送失败。

    可以事先建立好「公开 (Public)」仓库来解决（或更改 Docker Hub 账号的 Default repository privacy 设置）。

## 4. 使用示例

### 4.1. Basic 版本使用示例

适合基础网络调试和连通性测试：

```yaml
services:
  network-helper:
    image: ghcr.io/icasture/network-helper:noble-basic
    container_name: network-helper-basic
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

### 4.2. Standard 版本使用示例

适合网络性能测试和深度诊断：

```yaml
services:
  network-helper-standard:
    image: ghcr.io/icasture/network-helper:noble-standard
    container_name: network-helper-standard
    ports:
      - '34567:5432'
      - '5201:5201'  # iperf3 性能测试端口
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

### 4.3. Advanced 版本使用示例

适合安全分析和高级网络监控：

```yaml
services:
  network-helper-advanced:
    image: ghcr.io/icasture/network-helper:noble-advanced
    container_name: network-helper-advanced
    ports:
      - '34567:5432'
      - '8080:8080'  # mitmproxy Web 界面
      - '8081:8081'  # mitmproxy 代理端口
    networks:
      - global-network-helper-net
      - global-postgres-vector-net
    cap_add:
      - NET_ADMIN  # 某些高级网络工具需要额外权限
    privileged: false  # 根据需要启用

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
