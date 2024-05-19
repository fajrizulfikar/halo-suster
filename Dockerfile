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

# Replace placeholder values in .env.example with actual values
RUN sed -i "s/DB_NAME/$DB_NAME/g" .env.example \
    && sed -i "s/DB_PORT/$DB_PORT/g" .env.example \
    && sed -i "s/DB_HOST/$DB_HOST/g" .env.example \
    && sed -i "s/DB_USERNAME/$DB_USERNAME/g" .env.example \
    && sed -i "s/DB_PASSWORD/$DB_PASSWORD/g" .env.example \
    && sed -i "s/DB_PARAMS/$DB_PARAMS/g" .env.example \
    && sed -i "s/JWT_SECRET/$JWT_SECRET/g" .env.example \
    && sed -i "s/BCRYPT_SALT/$BCRYPT_SALT/g" .env.example \
    && sed -i "s/AWS_REGION/$AWS_REGION/g" .env.example \
    && sed -i "s/AWS_S3_BUCKET_NAME/$AWS_S3_BUCKET_NAME/g" .env.example \
    && sed -i "s/AWS_ACCESS_KEY_ID/$AWS_ACCESS_KEY_ID/g" .env.example \
    && sed -i "s/AWS_SECRET_ACCESS_KEY/$AWS_SECRET_ACCESS_KEY/g" .env.example

# Rename .env.example to .env
RUN mv .env.example .env

# Debugging step to verify .env file is present
RUN ls -al

# Print env values
RUN cat .env

RUN go mod download

RUN GOOS=linux GOARCH=amd64 go build -o /main ./cmd/main.go

RUN ls -al

FROM alpine
WORKDIR /app

COPY --from=builder /main .
COPY --from=builder .env .

# Expose port 8080 for the container
EXPOSE 8080

CMD ["/app/main"]