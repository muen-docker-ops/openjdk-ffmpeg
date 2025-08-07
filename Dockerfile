FROM linuxserver/ffmpeg:7.0.2

# 使用 root 用户
USER root

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        wget \
        xz-utils \
        openjdk-21-jdk \
    ; \
    \
    # 检测架构并设置 URL 和 JAVA_HOME
    arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
    url='https://github.com/yt-dlp/yt-dlp/releases/download/2024.11.18/yt-dlp_linux'; \
    case "$arch" in \
        'amd64') \
            JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"; \
        ;; \
        'arm64') \
            url="${url}_aarch64"; \
            JAVA_HOME="/usr/lib/jvm/java-21-openjdk-arm64"; \
        ;; \
        *) \
            echo "Unsupported architecture: $arch" >&2; exit 1; \
        ;; \
    esac; \
    \
    # 下载 yt-dlp 并设置执行权限
    wget -O /usr/local/bin/yt-dlp "$url" --progress=dot:giga; \
    chmod a+x /usr/local/bin/yt-dlp; \
    \
    # 将 JAVA_HOME 写入 shell 的默认环境
    echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile.d/java.sh; \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh; \
    chmod +x /etc/profile.d/java.sh; \
    \
    # 清理
    rm -rf \
        /tmp/* \
        /usr/share/doc/* \
        /var/cache/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /var/log/*

# 在启动时动态加载 JAVA_HOME
ENTRYPOINT ["/bin/bash", "-c", "source /etc/profile && exec \"$@\"", "--"]
