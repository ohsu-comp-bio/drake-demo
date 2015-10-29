FROM ipython/scipystack

WORKDIR /root/

# Install Java
RUN apt-get update
RUN apt-get install -y default-jre

# Install Drake
ADD https://raw.githubusercontent.com/Factual/drake/master/bin/drake /usr/local/bin/drake
RUN chmod a+x /usr/local/bin/drake

# Run Drake once to download it.
RUN drake --version

# Needed for Drake to run commands in Docker
ENV SHELL /bin/bash
