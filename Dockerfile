FROM node:10-alpine AS builder
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
WORKDIR /build
COPY . .
RUN npm install && npm run build

# Based on https://github.com/nsourov/Puppeteer-with-xvfb
FROM node:10

RUN apt-get update &&\
	apt-get install -yq gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 libdbus-1-3 \
	libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 libgtk-3-0 libnspr4 \
	libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 libxcomposite1 \
	libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 \
	ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget \
	xvfb x11vnc x11-xkb-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic x11-apps

# Copy from https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
RUN apt-get update \
	&& apt-get install -y wget gnupg \
	&& wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
	&& sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
	&& apt-get update \
	&& apt-get install -y google-chrome-unstable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

WORKDIR /app

COPY package*.json /app/
COPY entrypoint.sh /app/

RUN npm install --production --cache /tmp/cache && rm -rf /tmp/cache
COPY --from=builder /build/dist ./dist/

ENV DISPLAY :99

ENTRYPOINT ["/app/entrypoint.sh"]