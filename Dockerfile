FROM python:3.10-slim AS builder

ENV PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
	git python3-dev gcc && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/*

RUN git clone https://github.com/iya0/Heroku /Heroku

RUN python -m venv /Heroku/venv

RUN /Heroku/venv/bin/python -m pip install --upgrade pip

RUN /Heroku/venv/bin/pip install --no-warn-script-location --no-cache-dir -r /Heroku/requirements.txt

FROM python:3.10-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
	curl libcairo2 git ffmpeg libmagic1 libavcodec-dev libavutil-dev libavformat-dev \
	libswscale-dev libavdevice-dev neofetch wkhtmltopdf gcc python3-dev && \
	curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && apt-get install -y nodejs && \
	rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* && apt-get clean

ENV DOCKER=true \
	GIT_PYTHON_REFRESH=quiet \
	PIP_NO_CACHE_DIR=1 \
	PATH="/Heroku/venv/bin:$PATH"

COPY --from=builder /Heroku /Heroku

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /Heroku

EXPOSE 8080

ENTRYPOINT ["/entrypoint.sh"]
