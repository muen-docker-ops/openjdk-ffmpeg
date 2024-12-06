FROM linuxserver/ffmpeg:7.0.2
# 安装OpenJDK 11
USER root

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		wget \
		xz-utils \
        openjdk-11-jdk \
	; \
	apt-mark auto '.*' > /dev/null; \
	\
	arch="$(dpkg --print-architecture)"; arch="${arch##*-}"; \
	url='https://github.com/yt-dlp/yt-dlp/releases/download/2024.12.03/yt-dlp_linux'; \
	case "$arch" in \
		'amd64') \
            export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64; \
		;; \
		'arm64') \
			url="${url}_aarch64"; \
            export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-arm64; \
		;; \
		*) \
			exit 0; \
		;; \
	esac; \
	\
    wget -O /usr/local/bin/yt-dlp "$url" --progress=dot:giga; \
    chmod a+x /usr/local/bin/yt-dlp ; \
	fi; \
	\
	# Clean up \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf \
		/tmp/* \
		/usr/share/doc/* \
		/var/cache/* \
		/var/lib/apt/lists/* \
		/var/tmp/* \
		/var/log/*

# 添加JAVA_HOME到PATH
ENV PATH $JAVA_HOME/bin:$PATH

ENTRYPOINT ["/bin/bash"]