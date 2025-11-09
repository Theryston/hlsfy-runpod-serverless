FROM python:3.11

RUN apt-get update && apt-get install -y ffmpeg git make g++ curl
RUN curl -fsSL https://bun.com/install | bash
ENV BUN_INSTALL="/root/.bun"
ENV PATH="$BUN_INSTALL/bin:$PATH"

WORKDIR /hlsfy

RUN git clone https://github.com/Theryston/hlsfy.git .

RUN bun install

RUN chmod +x ./start.sh

WORKDIR /hlsfy-runpod

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

RUN chmod +x entrypoint.sh

ENTRYPOINT ["/bin/sh", "entrypoint.sh"]