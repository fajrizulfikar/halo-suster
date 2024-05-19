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
RUN sed -i "s/DB_NAME/$(echo "$DB_NAME" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/DB_PORT/$(echo "$DB_PORT" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/DB_HOST/$(echo "$DB_HOST" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/DB_USERNAME/$(echo "$DB_USERNAME" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/DB_PASSWORD/$(echo "$DB_PASSWORD" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/DB_PARAMS/$(echo "$DB_PARAMS" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/JWT_SECRET/$(echo "$JWT_SECRET" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/BCRYPT_SALT/$(echo "$BCRYPT_SALT" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/AWS_REGION/$(echo "$AWS_REGION" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/AWS_S3_BUCKET_NAME/$(echo "$AWS_S3_BUCKET_NAME" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/AWS_ACCESS_KEY_ID/$(echo "$AWS_ACCESS_KEY_ID" | sed 's/[\/&]/\\&/g')/g" .env.example \
    && sed -i "s/AWS_SECRET_ACCESS_KEY/$(echo "$AWS_SECRET_ACCESS_KEY" | sed 's/[\/&]/\\&/g')/g" .env.example

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

RUN ls -al

COPY .env .env

# Expose port 8080 for the container
EXPOSE 8080

CMD ["/app/main"]