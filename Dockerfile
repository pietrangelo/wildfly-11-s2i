# This image provides a base for building and running WildFly applications.
# It builds using maven and runs the resulting artifacts on WildFly 11.0.0 Final

FROM centos/s2i-base-centos7

MAINTAINER Pietrangelo Masala <p.masala@entando.com>

EXPOSE 8080 9990 8181 8888 11211 11222 57600 7600 45700 45688 23364 4712 4713

ENV WILDFLY_VERSION=11.0.0.Final \
    MAVEN_VERSION=3.5.2

LABEL io.k8s.description="Platform for building and running JEE applications on WildFly 11.0.0.Final" \
      io.k8s.display-name="WildFly 11.0.0.Final" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,wildfly,wildfly11" \
      io.openshift.s2i.destination="/opt/s2i/destination" \
      com.redhat.deployments-dir="/wildfly/standalone/deployments"

# Install Maven, Wildfly 
RUN INSTALL_PKGS="tar git ImageMagick unzip bc which lsof java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    (curl -v https://www.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | \
    tar -zx -C /usr/local) && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    mkdir -p /wildfly && \
    (curl -v https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz | tar -zx --strip-components=1 -C /wildfly) && \
    mkdir -p /opt/s2i/destination && \
    mkdir -p $HOME/.m2/repository

# Add s2i wildfly customizations
ADD ./contrib/wfmodules/ /wildfly/modules/
ADD ./contrib/wfbin/standalone.conf /wildfly/bin/standalone.conf
ADD contrib/wfcfg/standalone-ha-completo.xml /wildfly/standalone/configuration/standalone-ha.xml
ADD ./contrib/wfcfg/standalone.xml /wildfly/standalone/configuration/standalone.xml
ADD ./contrib/settings.xml $HOME/.m2/

# install All Entando dependencies on the EN-4.3.2-CloudNative tag
RUN git clone https://github.com/entando/entando-core.git && \
    git clone https://github.com/entando/entando-components.git && \
    git clone https://github.com/entando/entando-archetypes.git && \
    cd entando-core && git checkout EN-4.3.2-CloudNative && mvn -Dmaven.repo.local=/opt/s2i/destination/artifacts/.m2/repository install -DskipTests && mvn clean && \
    cd ../entando-components && git checkout EN-4.3.2-CloudNative && mvn -Dmaven.repo.local=/opt/s2i/destination/artifacts/.m2/repository install -DskipTests && mvn clean && \
    cd ../entando-archetypes && git checkout EN-4.3.2-CloudNative && mvn -Dmaven.repo.local=/opt/s2i/destination/artifacts/.m2/repository install -DskipTests && mvn clean && \
    rm -rf /opt/app-root/src/entando*

# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
COPY ./s2i/bin/ $STI_SCRIPTS_PATH

RUN chown -R 1001:0 /wildfly && chown -R 1001:0 $HOME && \
    chmod -R ug+rw /wildfly && chmod -R ug+rw $HOME && \
    chmod -R g+rw /opt/s2i/destination

USER 1001

CMD $STI_SCRIPTS_PATH/usage
