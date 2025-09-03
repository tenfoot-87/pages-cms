# ---- deps ----
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

# ---- build ----
FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# optional: run DB typegen/migrations at build time only if needed
# RUN npm run db:migrate --if-present
RUN npm run build && npm prune --omit=dev

# ---- run ----
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app ./
# run as non-root
RUN addgroup -S app && adduser -S app -G app
USER app
EXPOSE 3000
CMD ["npm","start"]
