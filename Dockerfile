# # Set the python version as a build-time argument
# # with Python 3.12 as the default
# ARG PYTHON_VERSION=3.12-slim-bullseye
# FROM python:${PYTHON_VERSION}

# # Create a virtual environment
# RUN python -m venv /opt/venv

# # Set the virtual environment as the current location
# ENV PATH=/opt/venv/bin:$PATH

# # Upgrade pip
# RUN pip install --upgrade pip

# # Set Python-related environment variables
# ENV PYTHONDONTWRITEBYTECODE 1
# ENV PYTHONUNBUFFERED 1

# # Install os dependencies for our mini vm
# RUN apt-get update && apt-get install -y \
#     # for postgres
#     libpq-dev \
#     # for Pillow
#     libjpeg-dev \
#     # for CairoSVG
#     libcairo2 \
#     # other
#     gcc \
#     && rm -rf /var/lib/apt/lists/*

# # Create the mini vm's code directory
# RUN mkdir -p /code

# # Set the working directory to that same code directory
# WORKDIR /code

# # Copy the requirements file into the container
# COPY requirements.txt /tmp/requirements.txt

# # copy the project code into the container's working directory
# COPY ./ /code

# # Install the Python project requirements
# RUN pip install -r /tmp/requirements.txt

# # database isn't available during build
# # run any other commands that do not need the database
# # such as:
# RUN python manage.py vendor_pull
# RUN python manage.py collectstatic --noinput

# # set the Django default project name
# ARG PROJ_NAME="core"

# ARG DJANGO_DEBUG=1
# ENV DJANGO_DEBUG=${DJANGO_DEBUG}

# ARG DJANGO_SECRET_KEY
# ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

# # create a bash script to run the Django project
# # this script will execute at runtime when
# # the container starts and the database is available
# RUN printf "#!/bin/bash\n" > ./paracord_runner.sh && \
#     printf "RUN_PORT=\"\${PORT:-8000}\"\n\n" >> ./paracord_runner.sh && \
#     printf "python manage.py migrate --no-input\n" >> ./paracord_runner.sh && \
#     printf "gunicorn ${PROJ_NAME}.wsgi:application --bind \"0.0.0.0:\$RUN_PORT\"\n" >> ./paracord_runner.sh

# # make the bash script executable
# RUN chmod +x paracord_runner.sh

# # Clean up apt cache to reduce image size
# RUN apt-get remove --purge -y \
#     && apt-get autoremove -y \
#     && apt-get clean \
#     && rm -rf /var/lib/apt/lists/*

# Set the Python version as a build-time argument
ARG PYTHON_VERSION=3.12-slim-bullseye
FROM python:${PYTHON_VERSION}

# Create a virtual environment
RUN python -m venv /opt/venv

# Set the virtual environment as the current PATH
ENV PATH=/opt/venv/bin:$PATH

# Upgrade pip
RUN pip install --upgrade pip

# Set Python-related environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# # Install os dependencies for our mini vm
RUN apt-get update && apt-get install -y \
    # for postgres
    libpq-dev \
    # for Pillow
    libjpeg-dev \
    # for CairoSVG
    libcairo2 \
    # other
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Create the application directory
RUN mkdir -p /code

# Set the working directory
WORKDIR /code

# Copy requirements file into the container
COPY requirements.txt /tmp/requirements.txt

# Install the Python dependencies
RUN pip install -r /tmp/requirements.txt

# Copy the project code into the container
COPY ./ /code

# Set build-time arguments
ARG PROJ_NAME="core"
ARG DJANGO_DEBUG=1
ENV DJANGO_DEBUG=${DJANGO_DEBUG}

ARG DJANGO_SECRET_KEY
ENV DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY}

RUN mkdir -p /code/staticfiles/vendors

# Defer static collection, vendor pull, and database migrations to runtime
RUN printf "#!/bin/bash\n" > ./paracord_runner.sh && \
    printf "RUN_PORT=\"\${PORT:-8000}\"\n\n" >> ./paracord_runner.sh && \
    printf "python manage.py migrate --no-input\n" >> ./paracord_runner.sh && \
    printf "python manage.py collectstatic --noinput\n" >> ./paracord_runner.sh && \
    printf "python manage.py vendor_pull\n" >> ./paracord_runner.sh && \
    printf "gunicorn ${PROJ_NAME}.wsgi:application --bind \"0.0.0.0:\$RUN_PORT\"\n" >> ./paracord_runner.sh

# Make the runtime script executable
RUN chmod +x paracord_runner.sh

# Clean up apt cache to reduce image size
RUN apt-get remove --purge -y \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Use the bash script to run the Django project at runtime
CMD ./paracord_runner.sh

