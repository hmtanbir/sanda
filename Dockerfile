FROM ruby:3.3.6-alpine

# Install dependencies
#RUN apt-get update -qq && apt-get install -y build-essential default-mysql-client libpq-dev nodejs yarn redis-tools curl

RUN apk add --no-cache build-base mysql-client mariadb-dev postgresql-dev nodejs yarn redis curl bash

# Set working directory
WORKDIR /app

COPY ./ .

# install gems
RUN bundle install

# Set environment variables
ENV RAILS_ENV=development

# Expose port
EXPOSE 3000

RUN chmod +x entrypoints/entrypoint.sh
# Start Rails server
ENTRYPOINT ["./entrypoints/entrypoint.sh"]
