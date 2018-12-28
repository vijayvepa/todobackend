FROM jmenga/todobackend-base:latest
MAINTAINER Justin Menga <justin.menga@gmail.com>

# Insall dev/build dependencies
RUN apt-get update && \
	apt-get install -qy python-dev libmysqlclient-dev 

# Activate virtual environment and install wheel support
RUN . /appenv/bin/activate && \
	pip install wheel --upgrade 

# PIP environment variables (NOTE: must be set after installing wheel)
ENV WHEELHOUSE=/wheelhouse PIP_WHEEL_DIR=/wheelhouse PIP_FIND_LINKS=/wheelhouse XDG_CACHE_HOME=/cache 

# OUTPUT: build artifacts (wheels) are output here
VOLUME /wheelhouse

# OUTPUT: Test Reports are output here:
VOLUME /reports 

# Add Test Entrypoint script
COPY scripts/test.sh /usr/local/bin/test.sh
RUN chmod +x /usr/local/bin/test.sh

# Set defaults for the entrypoint and command string
ENTRYPOINT ["test.sh"]
CMD ["python", "manage.py", "test" ,"--noinput"]

# Add appliction source code 
# running these items after above steps improves performance as above steps don't change often.
COPY src /application
WORKDIR /application