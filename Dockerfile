FROM --platform=linux/amd64 golang:1.22-alpine AS builder

WORKDIR /app

COPY . .

# Define build arguments for environment variables
ARG DB_NAME
ARG DB_PORT
ARG DB_HOST
ARG DB_USERNAME
ARG DB_PASSWORD
ARG DB_PARAMS
ARG JWT_SECRET
ARG BCRYPT_SALT
ARG AWS_REGION
ARG AWS_S3_BUCKET_NAME
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY

# Create the .env file using build arguments
RUN echo "DB_NAME=$DB_NAME" > .env \
    && echo "DB_PORT=$DB_PORT" >> .env \
    && echo "DB_HOST=$DB_HOST" >> .env \
    && echo "DB_USERNAME=$DB_USERNAME" >> .env \
    && echo "DB_PASSWORD=$DB_PASSWORD" >> .env \
    && echo "DB_PARAMS=$DB_PARAMS" >> .env \
    && echo "JWT_SECRET=$JWT_SECRET" >> .env \
    && echo "BCRYPT_SALT=$BCRYPT_SALT" >> .env \
    && echo "AWS_REGION=$AWS_REGION" >> .env \
    && echo "AWS_S3_BUCKET_NAME=$AWS_S3_BUCKET_NAME" >> .env \
    && echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID" >> .env \
    && echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY" >> .env

RUN go mod download

RUN GOOS=linux GOARCH=amd64 go build -o /main ./cmd/main.go

FROM alpine
WORKDIR /app

COPY --from=builder /main .

# Expose port 8080 for the container
EXPOSE 8080

CMD ["/app/main"]