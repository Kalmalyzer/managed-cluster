FROM ubuntu:noble

RUN apt-get update
RUN apt-get install curl gpg -y

# Add Perforce's package repository as a source for apt
RUN curl -sS https://package.perforce.com/perforce.pubkey | gpg --dearmor -o /usr/share/keyrings/perforce.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/perforce.gpg] http://package.perforce.com/apt/ubuntu noble release" > /etc/apt/sources.list.d/perforce.list
RUN apt-get update

# Install Perforce P4D Server
RUN apt-get install p4-server=2025.1-2810567~noble -y
RUN apt-get clean

# The apt package creates a user called 'perforce' with UID=100 & GID=101
ARG GROUP=perforce
ARG USER=perforce

# Add startup script
WORKDIR /
COPY docker-entrypoint.sh /
RUN chmod 500 /docker-entrypoint.sh
RUN chown ${USER}:${GROUP} /docker-entrypoint.sh

# Create data directories
RUN mkdir /metadata && mkdir /library && mkdir /journals && mkdir /backup && mkdir /ssl
RUN chown ${USER}:${GROUP} /metadata /library /journals /backup /ssl
RUN chmod 700 /ssl

USER ${USER}

# Set default environment variables
ENV P4PORT=ssl:1666
ENV P4ROOT=/metadata
ENV P4NAME=myserver
ENV P4JOURNAL=/journals/journal
ENV P4SSLDIR=/ssl

ENTRYPOINT ["/docker-entrypoint.sh"]
