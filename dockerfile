FROM debian as jdk_runtime 
# jdk环境
ARG LAB_VERSION=0.3-SNAPSHOT
ENV LAB_VERSION=${LAB_VERSION}

RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources && apt update

RUN apt install -y maven 

RUN apt install -y openjdk-17-jre

RUN apt install -y ghostscript 

RUN apt install -y pdf2svg

RUN apt install -y texlive-extra-utils

FROM jdk_runtime as builder
# mvn构建环境
COPY . /app/data

RUN rm /etc/maven/settings.xml && cp /app/data/settings.xml /etc/maven/settings.xml

WORKDIR /app/data/antlr4-lab

RUN mvn clean package

RUN mv target/antlr4-lab-$LAB_VERSION-complete.jar /app/antlr4-lab-$LAB_VERSION-complete.jar

FROM jdk_runtime as runner

# 运行环境
WORKDIR /app

COPY --from=builder /app/antlr4-lab-$LAB_VERSION-complete.jar /app/antlr4-lab-$LAB_VERSION-complete.jar
COPY --from=builder /app/data/antlr4-lab/src /app/src
COPY --from=builder /app/data/antlr4-lab/resources /app/resources
COPY --from=builder /app/data/antlr4-lab/static /app/static
COPY --from=builder /app/data/antlr4-lab/pom.xml /app/pom.xml

ENTRYPOINT java -jar /app/antlr4-lab-$LAB_VERSION-complete.jar

EXPOSE 80