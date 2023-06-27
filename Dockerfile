# syntax=docker/dockerfile:1.5-labs

ARG GIT_TAG=${GIT_TAG:-master}

FROM node:lts as node

ARG GIT_TAG
ENV PATH="${PATH}:/root/.cargo/bin"

WORKDIR /app

ADD https://github.com/joamag/boytacean.git#${GIT_TAG} .

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y  

RUN cargo install wasm-pack && \
    wasm-pack build --release --target=web --out-dir=frontends/web/lib -- --features wasm

RUN cd frontends/web && npm install 
RUN cd frontends/web && npm run build

FROM python:3.12.0b3-alpine as app

COPY --from=node /app/frontends/web/dist /app

WORKDIR /app

ADD roms.tar.gz .

EXPOSE 8000

CMD [ "python3", "-m", "http.server"]