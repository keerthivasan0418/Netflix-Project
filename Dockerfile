# --- Build stage ---
FROM node:16.17.0-alpine as builder
WORKDIR /app

# Copy dependency files
COPY ./package.json ./
COPY ./yarn.lock ./
RUN yarn install

# Copy source code
COPY . .

# Accept TMDB API key from Jenkins (build arg)
ARG TMDB_V3_API_KEY

# ✅ Match exactly what your frontend expects
ENV VITE_APP_TMDB_V3_API_KEY=${TMDB_V3_API_KEY}
ENV VITE_APP_API_ENDPOINT_URL="https://api.themoviedb.org/3"

# Build the React/Vite app
RUN yarn build

# --- Runtime stage ---
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
