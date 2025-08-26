# ===== Builder Stage =====
FROM python:3.10-slim-bullseye AS builder

ENV PIP_NO_CACHE_DIR=1

# Instala pacotes essenciais para build de dependências Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    git python3-dev gcc build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/archives/*

# Clona o repositório
RUN git clone https://github.com/itsnoly/Heroku /Heroku

# Cria um ambiente virtual
RUN python -m venv /Heroku/venv

# Atualiza pip
RUN /Heroku/venv/bin/python -m pip install --upgrade pip

# Instala dependências do Python
RUN /Heroku/venv/bin/pip install --no-warn-script-location --no-cache-dir -r /Heroku/requirements.txt

# ===== Final Stage =====
FROM python:3.10-slim-bullseye

ENV DOCKER=true \
    GIT_PYTHON_REFRESH=quiet \
    PIP_NO_CACHE_DIR=1 \
    PATH="/Heroku/venv/bin:$PATH"

# Instala dependências de sistema
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        git \
        ffmpeg \
        libcairo2 \
        libmagic1 \
        libavcodec-dev \
        libavutil-dev \
        libavformat-dev \
        libswscale-dev \
        neofetch \
        wkhtmltopdf \
        gcc \
        python3-dev \
        build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/archives/*

# Instala Node.js 18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/cache/apt/archives/*

# Copia o ambiente virtual do builder
COPY --from=builder /Heroku /Heroku

# Copia o entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /Heroku
EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]