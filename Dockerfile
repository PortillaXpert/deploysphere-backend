FROM python:3.11-slim-bullseye AS build 

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libmariadb-dev && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip &&\
    pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim-buster

WORKDIR /app

COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=build /usr/local/bin /usr/local/bin

COPY . .

EXPOSE 8000

CMD ["gunicorn","myproject.wsgi:application", "--bind", "0.0.0.0:8000", "--timeout", "300", "--workers", "3"]