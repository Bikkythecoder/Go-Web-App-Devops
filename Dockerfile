# ==========================
# Stage 1 - Build the application
# ==========================
FROM golang:1.26.5 AS builder

# Set working directory
WORKDIR /app

# Copy dependency files
COPY go.mod .

# Download Go modules
RUN go mod download

# Copy the application source code
COPY . .

# Build a statically linked Linux binary
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -o main .

# ==========================
# Stage 2 - Runtime image
# ==========================
FROM gcr.io/distroless/static-debian12

# Set working directory
WORKDIR /

# Copy the compiled binary
COPY --from=builder /app/main /main

# Copy static files (if your application has them)
COPY --from=builder /app/static /static

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["/main"]