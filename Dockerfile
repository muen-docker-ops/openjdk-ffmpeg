FROM linuxserver/ffmpeg:7.0.2
# 安装OpenJDK 11
USER root
RUN sed -i 's/deb.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get clean;

# 设置JAVA_HOME环境变量
ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64

# 添加JAVA_HOME到PATH
ENV PATH $JAVA_HOME/bin:$PATH

ENTRYPOINT ["/bin/bash"]