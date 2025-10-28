# ---- Base ----
FROM node:22 AS base
WORKDIR /usr/src/app
COPY package*.json ./
# Variável para ambiente de produção, pode ser sobrescrita no docker-compose
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

# ---- Dependencies ----
FROM base AS dependencies
# Instala apenas dependências de produção se NODE_ENV=production
RUN if [ "$NODE_ENV" = "production" ]; then \
      npm ci --omit=dev; \
    else \
      npm ci; \
    fi

# ---- Build ----
FROM base AS build
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
COPY . .
# Constrói o projeto TypeScript para JavaScript
RUN npm run build

# ---- Release ----
FROM node:22-alpine AS release
WORKDIR /usr/src/app
# Copia dependências de produção
COPY --from=dependencies /usr/src/app/node_modules ./node_modules
# Copia a build do estágio anterior
COPY --from=build /usr/src/app/dist ./dist
# Copia package.json (pode ser útil para algumas libs)
COPY package.json ./

# Define um usuário não-root para rodar a aplicação (melhor prática de segurança)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

# Expõe a porta que a aplicação vai rodar (será definida pela env var PORT)
# Não é estritamente necessário se usar docker-compose, mas é boa prática
EXPOSE ${PORT}
# Comando para iniciar a aplicação em produção
CMD ["node", "dist/main"]