FROM ruby:3.2-slim-bookworm
RUN apt-get update && apt-get install -y build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile ./
RUN bundle install

COPY . .

CMD ["bundle", "exec", "rackup", "--port", "8080", "--host", "0.0.0.0"]
