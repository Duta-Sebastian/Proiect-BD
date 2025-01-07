FROM python:3.11-slim AS builder

ENV POETRY_VERSION=1.8.5
ENV POETRY_HOME=/opt/poetry
ENV POETRY_VENV=/opt/poetry-venv
ENV POETRY_CACHE_DIR=/opt/.cache

RUN python3 -m venv $POETRY_VENV \
    && $POETRY_VENV/bin/pip install -U pip setuptools \
    && $POETRY_VENV/bin/pip install poetry==${POETRY_VERSION}

ENV PATH="${PATH}:${POETRY_VENV}/bin"

RUN apt-get update && apt-get install -y gcc libaio1 unzip wget

RUN wget --no-check-certificate https://download.oracle.com/otn_software/linux/instantclient/2360000/instantclient-basic-linux.x64-23.6.0.24.10.zip && \
    unzip instantclient-basic-linux.x64-23.6.0.24.10.zip && \
    mv instantclient_23_6 /opt/instantclient

ENV ORACLE_HOME=/opt/instantclient
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/instantclient
ENV PATH=$PATH:/opt/instantclient

WORKDIR /python_api

COPY ./../python_api/poetry.lock .
COPY ./../python_api/pyproject.toml .

RUN poetry install --no-interaction --no-ansi

COPY ./../python_api/ .

EXPOSE 5000

ENV FLASK_APP=app.py
ENV PYTHONPATH=/python_api
ENV PYTHONPATH="${PYTHONPATH}:/"

CMD ["poetry", "run", "gunicorn", "--log-level", "debug", "--workers", "3", "--bind", "0.0.0.0:5000", "python_api.app:app"]
