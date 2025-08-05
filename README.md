
<img width="1920" height="346" alt="sanda-design" src="https://github.com/user-attachments/assets/5e82e9df-656d-4809-beb3-c5597e57b420" />

# Sanda - Zero Config API Boilerplate with Ruby on Rails
![Static Badge](https://img.shields.io/badge/license-MIT-red) ![Static Badge](https://img.shields.io/badge/version-1.0.0-cyan)
![Static Badge](https://img.shields.io/badge/bundler-2.7.1-blue) ![Static Badge](https://img.shields.io/badge/ruby-3.3.6-red)
![Static Badge](https://img.shields.io/badge/rails-8.x.x-yellow) ![Static Badge](https://img.shields.io/badge/postgresql-14.x-green)
![Static Badge](https://img.shields.io/badge/redis-7.x-blue) ![Static Badge](https://img.shields.io/badge/coverage-100%25-green)

Sanda is a zero-config API boilerplate with Ruby on Rails, PostgreSQL 14.x, Pundit and comes with excellent user and role management API out of the box. 
Start your next big API project with Sanda, focus on building business logic, and save countless hours of writing boring user and role management API again and again.

Sanda works with Ruby on Rails 8.x., PostgresSQL 14.x, Redis 7.x

- [Sanda - Zero Config API Boilerplate with Ruby on Rails](#hydra---zero-config-api-boilerplate-with-ruby-on-rails)
    - [Requirements](#requirements)
    - [Getting Started](#getting-started)
        - [Without Docker (Simple)](#without-docker-simple)
          - [Install the dependencies](#install-the-dependencies)
          - [Database Migration and Seeding](#database-migration-and-seeding)
        - [Using Docker](#using-docker)
          - [Prepare docker compose file](#prepare-docker-compose-file)
          - [Build docker container](#build-docker-container)
          - [Run docker container](#run-docker-container)
          - [Stop docker container](#stop-docker-container)
          - [Remove docker container](#remove-docker-container)
        - [Screencasts](#screencasts)
          - [Install sanda with postgresql without Docker](#install-sanda-with-postgresql-without-docker)
          - [Install sanda with mysql without Docker](#install-sanda-with-mysql-without-docker)
          - [Install sanda with postgresql with Docker](#install-sanda-with-postgresql-using-docker)
          - [Install sanda with mysql with Docker](#install-sanda-with-mysql-using-docker)
    - [List of Default Routes](#list-of-default-routes)
    - [Default Roles](#default-roles)
    - [Routes Documentation](#routes-documentation)
        - [User Registration](#user-registration)
        - [User Authentication/Login (Admin)](#user-authenticationlogin-admin)
        - [User Authentication/Login (Other Roles)](#user-authenticationlogin-other-roles)
        - [List Users (Admin Ability Required)](#list-users-admin-ability-required)
        - [Update a User (User/Admin Ability Required)](#update-a-user-useradmin-ability-required)
        - [Delete a User (Admin Ability Required)](#delete-a-user-admin-ability-required)
        - [Add a New Role](#add-a-new-role-admin-ability-required)
        - [Update a Role](#update-a-role-admin-ability-required)
        - [Delete a Role](#delete-a-role-admin-ability-required)
    - [Notes](#notes)
        - [Default Admin Username and Password](#default-admin-username-and-password)
        - [Default Role for New Users](#default-role-for-new-users)
        - [Single Session or Multiple Session](#single-session-or-multiple-session)
        - [Add `Accept: application/json` Header In Your API Calls (Important)](#add-accept-applicationjson-header-in-your-api-calls-important)
        - [Logging](#logging)
        - [Code Formatting](#code-formatting)
        - [RSpec Testing](#rspec-testing)
    - [Tutorial](#tutorial)
        - [Create a New API Controller](#create-a-new-api-controller)
        - [Add a Function](#add-a-function)
        - [Create Protected Routes](#create-protected-routes)
        - [Create Authorization Policy](#create-authorization-policy)
        - [Test Protected Routes](#test-protected-routes)

## Requirements

The setups steps expect following tools installed on the system.

- Ruby        => [3.3.6](javascript:void(0);)
- Rails       => [8.x](javascript:void(0);)
- PostgreSQL  => [14.x](javascript:void(0);) or MySQL => [9.x](javascript:void(0);)
- Redis       => [7.x](javascript:void(0);)

## Getting Started

It's super easy to get Sanda up and running.

First clone the project and change the directory

```shell
git clone https://github.com/hmtanbir/sanda.git
cd sanda
```

Then follow the process using either Docker or without Docker (simple).

### Without Docker (Simple)

## Install the dependencies

1. Install project gems

```shell
bundle install --path=vendor
```

2. Prepare .env file

Copy .env.example file and paste as .env
```shell
cp .env.example .env
```

3. Generate application secret key and update .env file's `SECRET_KEY` value.

```shell
bundle exec rails secret
```

## Database Migration and Seeding

Open your `.env` file and change the DATABASE options. You can start by following these steps

1. Create a new database

```shell
bundle exec rails db:create
```

2. Run Migrations

```shell
bundle exec rails db:migrate
```

Now your database has essential tables for user and roles management.

3. Run Database Seeders

Run `db:seed`, and you have your first admin user, normal user, and the relationship correctly setup.

```shell
bundle exec rails db:seed
```

Please note that the default admin user is **admin@sanda.project** and the default password is **sanda-admin-123**. You should create a new admin user before deploying to production and delete this default admin user. You can do that using the available Sanda user management API or any DB management tool.

## Start the webserver

You can run server following command:

```shell
bundle exec rails server -p 3000 -b 0.0.0.0
```

That's mostly it! You have a fully running Ruby on Rails installation, all configured.

## Using Docker
If you want to use docker container, then you have to follow some steps following below:

### Prepare docker compose file

You need to prepare docker compose file at first based on database. 
If you use postgresql database, then use `docker-compose.pg.yml`

```shell
cp -r docker-compose.pg.yml docker-compose.yml
```

OR, If you use mysql database, then use `docker-compose.mysql.yml`

```shell
cp -r docker-compose.mysql.yml docker-compose.yml
```

Now, your docker compose file is ready to build.

### Build docker container

Build your docker container following command:

```shell
docker-compose build --no-cache
```

### Run docker container

Now, We will run the container following command:

```shell
docker-compose up -d
```

### Stop docker container

Now, We will run the container following command:

```shell
docker-compose down
```

### Remove docker container
If you want remove container with it's volumes following the command:

```shell
docker-compose down --volumes --remove-orphans
```

## Screencasts

### Install Sanda with postgresql (without docker)

[![asciicast](https://asciinema.org/a/731736.svg)](https://asciinema.org/a/731736)

### Install Sanda with mysql (without docker)
[![asciicast](https://asciinema.org/a/731741.svg)](https://asciinema.org/a/731741)

### Install Sanda with postgresql (using docker)
[![asciicast](https://asciinema.org/a/731743.svg)](https://asciinema.org/a/731743)

### Install Sanda with mysql (using docker)
[![asciicast](https://asciinema.org/a/731744.svg)](https://asciinema.org/a/731744)

## List of Default Routes

Here is a list of default routes. Run the following rails command to see this list in your terminal.

```shell
bundle exec rails routes
```

<img width="1897" height="615" alt="Screenshot 2025-08-05 at 4 58 41 PM" src="https://github.com/user-attachments/assets/19ff1187-0379-466d-a871-3d4855744247" />


## Default Roles

Sanda comes with these `admin` & `user` roles out of the box. For details, open the User model class.


## Routes Documentation

Let's have a look at what Sanda has to offer. Before experimenting with the following API endpoints, run your Sanda project using `rails server -p 3000 -b 0.0.0.0` command. For the next part of this documentation, we assumed that Sanda is listening at http://localhost:3000

### User Registration

You can make an `HTTP POST` call to create/register a new user to the following endpoint. Newly created users will have the `user` role by default.

```shell
http://localhost:3000/api/v1/registration
```

**API Payload & Response**

You can send a Form Multipart payload or a JSON payload like this.

```json
{
  "user": {
    "name": "Sanda User",
    "email": "user@sanda.project",
    "password": "sanda-user-123"
  }
}
```

Voila! Your user has been created and is now ready to log in!

If this user already exists, then you will receive a 422 Response like this

```json
{
  "status": 422,
  "message": [
    "Email has already been taken"
  ],
  "data": null
}
```

### User Authentication/Login (Admin)

Remember Sanda comes with the default admin user? You can log in as an admin by making an HTTP POST call to the following route.

```shell
http://localhost:3000/api/v1/sessions
```

**API Payload & Response**

You can send a Form Multipart or a JSON payload like this.

```json
{
  "user": {
    "email": "admin@sanda.project",
    "password": "sanda-admin-123"
  }
}
```

You will get a JSON response with user token. You need this admin token for making any call to other routes protected by admin ability.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTM3NjYzMzh9.fuaZL5O2meayrdQT0_YalMhp2hK_mOGPduyBKpsmZz0"
  }
}
```

For any unsuccessful attempt, you will receive a 401 error response.

For invalid email address:
```json
{
  "status": 404,
  "message": "invalid email",
  "data": null
}
```
For invalid password:
```json
{
    "status": 401,
    "message": "invalid password",
    "data": null
}
```

### User Authentication/Login (Other Roles)

You can log in as a user by making an HTTP POST call to the following route

```shell
http://localhost:3000/api/v1/sessions
```

**API Payload & Response**

You can send a Form Multipart or a JSON payload like this

```json
{
  "user": {
    "email": "user@sanda.project",
    "password": "sanda-user-123"
  }
}
```

You will get a JSON response with user token. You need this user token for making any calls to other routes protected by user ability.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NTM3NjYzMzh9.c3Pp9pSbH0UoY01NmSa9cydqqla2Jmqt0JhnbqPte8Q"
  }
}
```

For any unsuccessful attempt, you will receive a 401 error response.

For invalid email address:
```json
{
  "status": 404,
  "message": "invalid email",
  "data": null
}
```
For invalid password:
```json
{
    "status": 401,
    "message": "invalid password",
    "data": null
}
```

### List Users (Admin Ability Required)

To list the all users, make an `HTTP GET` call to the following route, with Admin Token obtained from Admin Login. Add this token as a standard `Bearer Token` to your API call.

```shell
http://localhost:3000/api/v1/users
```

**API request**

```shell
curl --location 'localhost:3000/api/v1/users' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTM3NjcwNzR9.JGNtk8hB2zSDBU05HtDw2BR0__6WHv7D5QFJjV1I4l0'
```

**API Payload**

No payload is required for this call.

**API response**
You will get a JSON response with all users available in your project.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@sanda.project",
      "role": "admin",
      "created_at": "2025-07-28T05:30:33.658Z",
      "updated_at": "2025-07-28T05:30:33.658Z",
      "deleted_at": null
    },
    {
      "id": 2,
      "name": "Regular User",
      "email": "user@sanda.project",
      "role": "user",
      "created_at": "2025-07-28T05:30:33.853Z",
      "updated_at": "2025-07-28T05:30:33.853Z",
      "deleted_at": null
    }
  ],
  "current_page": 1,
  "per_page": 10,
  "total_pages": 1,
  "total_count": 2,
  "next_page": null,
  "prev_page": null
}
```

To list the admin users, make an `HTTP GET` call to the following route, with Admin Token obtained from Admin Login. Add this token as a standard `Bearer Token` to your API call 
and a params role named "admin"

```shell
http://localhost:3000/api/v1/users?role=admin
```

**API request**

```shell
curl --location 'localhost:3000/api/v1/users?role=admin' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTM3NjcwNzR9.JGNtk8hB2zSDBU05HtDw2BR0__6WHv7D5QFJjV1I4l0'
```

**API Payload**

No payload is required for this call.

**API response**
You will get a JSON response with all users available in your project.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": [
    {
      "id": 1,
      "name": "Admin User",
      "email": "admin@sanda.project",
      "role": "admin",
      "created_at": "2025-07-28T05:30:33.658Z",
      "updated_at": "2025-07-28T05:30:33.658Z",
      "deleted_at": null
    }
  ],
  "current_page": 1,
  "per_page": 10,
  "total_pages": 1,
  "total_count": 1,
  "next_page": null,
  "prev_page": null
}
```

To list the admin users, make an `HTTP GET` call to the following route, with Admin Token obtained from Admin Login. Add this token as a standard `Bearer Token` to your API call
and a params role named "user"

```shell
http://localhost:3000/api/v1/users?role=user
```

**API request**

```shell
curl --location 'localhost:3000/api/v1/users?role=admin' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTM3NjcwNzR9.JGNtk8hB2zSDBU05HtDw2BR0__6WHv7D5QFJjV1I4l0'
```

**API Payload**

No payload is required for this call.

**API response**
You will get a JSON response with all users available in your project.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": [
    {
      "id": 2,
      "name": "Regular User",
      "email": "user@sanda.project",
      "role": "user",
      "created_at": "2025-07-28T05:30:33.853Z",
      "updated_at": "2025-07-28T05:30:33.853Z",
      "deleted_at": null
    }
  ],
  "current_page": 1,
  "per_page": 10,
  "total_pages": 1,
  "total_count": 1,
  "next_page": null,
  "prev_page": null
}
```


For any invalid token, you will receive a 401 error response.

```json
{
  "status": 401,
  "message": "Invalid token",
  "data": null
}
```

For any unsuccessful attempt or wrong token (other user token who have not any permission), you will receive a 403 error response.

```json
{
    "status": 403,
    "message": "unauthorized",
    "data": null
}
```


### Update a User (User/Admin Ability Required)

Make an `HTTP PUT` request to the following route to update an existing user. Replace {userId} with actual user id. You must include a Bearer token obtained from User/Admin authentication. A bearer admin token can update any user. A bearer user token can only update only his/her information.

```shell
http://localhost:8000/api/v1/users/{userId}
```

For example, to update the user with id 2, use this endpoint `http://localhost:3000/api/v1/users/2`

**API request**

```shell
curl --location --request PATCH 'localhost:3000/api/v1/users/2' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyLCJleHAiOjE3NTM3NjcwNzR9.MMFIA1OwwXkPpkmaEZbz4P6fGvKJ28Uy8PTsL6RgBa8' \
--header 'Content-Type: application/json' \
--data '{
    "user": {
        "name": "Sanda User 1",
        "email": "user@sanda.project"
    }
}'
```


**API Payload**

You can include `name` or `email`, or both in a JSON payload, just like this

```json
{
  "user": {
    "name": "Sanda User 1",
    "email": "user@sanda.project"
  }
}
```
**API Response**

You will receive the updated user if the bearer token is valid.

```json
{
  "status": 200,
  "message": "Successfully data updated",
  "data": {
    "id": 2,
    "name": "Sanda User 1",
    "email": "user@sanda.project",
    "role": "user",
    "created_at": "2025-07-28T05:30:33.853Z",
    "updated_at": "2025-07-28T05:30:33.853Z",
    "deleted_at": null
  }
}
```

For any unsuccessful attempt with an invalid token, you will receive a 401 error response.

```json
{
  "status": 401,
  "message": "Invalid token",
  "data": null
}
```

If a bearer user token attempts to update any other user but itself, a 401 error response will be delivered

```json
{
  "status": 401,
  "message": "unauthorized",
  "data": null
}
```

### Delete a User (Admin Ability Required)

To delete an existing user, make a `HTTP DELETE` request to the following route. Replace {userId} with actual user id

```shell
http://localhost:3000/api/v1/users/{userId}
```

For example to delete the user with id 2, use this endpoint `http://localhost:3000/api/v1/users/2`

**API Request**

```shell
curl --location --request DELETE 'localhost:3000/api/v1/users/2' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJleHAiOjE3NTM3NjcwNzR9.JGNtk8hB2zSDBU05HtDw2BR0__6WHv7D5QFJjV1I4l0'
```

**API Payload**

No payload is required for this call.

If the request is successful and the bearer token is valid, you will receive a JSON response like this

```json
{
  "status": 200,
  "message": "Successfully data deleted",
  "data": null
}
```

You will receive a 401 error response for any unsuccessful attempt with an invalid token.

```json
{
  "status": 401,
  "message": "Invalid token",
  "data": null
}
```

For any unsuccessful attempt with an invalid `user id`, you will receive a 404 not found error response. For example, you will receive the following response when you try to delete a non-existing user with id 16.

```json
{
  "status": 404,
  "message": "Couldn't find User with 'id'=20",
  "data": null
}
```

## Notes

### Default Admin Username and Password

When you run the database seeders, a default admin user is created with the username '**admin@sanda.project**' and the password '**sanda-admin-123**'. You can login as this default admin user and use the bearer token on next API calls where admin ability is required.

When you push your application to production, please remember to change this user's password, email or simply create a new admin user and delete the default one.

### Default Role for New Users

The `user` role is assigned to them when a new user is created. 

There are two default role in Sanda.

| Role Slug   | Role Name   | Rank |
|-------------|-------------|------|
| admin       | Admin       | 0    |
| user        | User        | 1    |  

This Role variables is configured in `config/roles.yml`. If you want to add more role, open `config/roles.yml` file and add your role in below the user role with rank. 
Suppose, you want to add a new role named `editor`. then, it will like below:

```yaml
# config/roles.yml
admin: 0
user: 1
editor: 2
```


### Single Session or Multiple Session

Sanda doesn't invalidate the previously issued access tokens when a user authenticates. So, all access tokens, including the newly created one, will remain valid.

### Add `Accept: application/json` Header In Your API Calls (Important)

This is very important. To properly receive JSON responses, add the following header to your API requests.

```shell
Accept: application/json
```

For example, if you are using `curl` you can make a call like this.

```shell
curl --location 'localhost:3000/api/v1/users/1' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoyLCJleHAiOjE3NTM3NjcwNzR9.MMFIA1OwwXkPpkmaEZbz4P6fGvKJ28Uy8PTsL6RgBa8' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json'
```

### Logging

Sanda comes with an excellent logger to log request headers, parameters and response to help debugging and inspecting API calls. Check log details into log folder.

### Code Formatting

Sanda comes with an excellent code formatter called [Rubocop](https://github.com/rubocop/rubocop) out of the box, with an excellent configuration preset.

To format your code using `rubocop`, you can run the following command any time from inside your project diretory.

```shell
bundle exec rubocop -a
```

And that's all for formatting. To know more, check out  rubocop documentation at [https://github.com/rubocop/rubocop](https://github.com/rubocop/rubocop)

### RSpec Testing

Sanda comes with 100% test coverage using RSpec. You can check testing following command:

```shell
bundle exec rspec
```

To check coverage, open the coverage file:

```shell
open coverage/index.html
```

<img width="1894" height="750" alt="Screenshot 2025-07-28 at 4 46 01 PM" src="https://github.com/user-attachments/assets/601250f9-568d-419d-b7d3-e3396b49d184" />



## Tutorial

So you decided to give Sanda a try and create a new protected API endpoint; that's awesome; let's dive in.

### Create a New API Controller

You can create a normal or a resourceful controller. To keep it simple, I am going with a standard controller.

```shell
rails generate controller API::V1::BlogsController
```
This will create a new controller file called `app/controlers/api/v1/blogs_controller.rb`

### Add a Function

We will add `index` function that will return `Hello Sanda` text.

Open this file `app/controlers/api/v1/blogs_controller.rb` and add the following code

```ruby
class Api::V1::BlogsController < ApplicationController
  def index
    data = "Hello Sanda"
    render_json_response(:ok, I18n.t("data.success.fetched"), data)
  end
end

```

### Create Protected Routes

Let's create a protected route `http://localhost:3000/api/v1/blogs` to use this API

Open your `config/routes` file and add the following line at the end.

```ruby
namespace :api do
  namespace :v1 do
    get "blogs/index", to: "blogs#index"
  end
end
```

### Create Authorization Policy
Let's create a authorization policy for the BlogsController. We assume that all authenticated user can see the blogs

Create a new policy named `blog_policy.rb` in `app/policies` folder add following codes:

```ruby
class BlogPolicy < ApplicationPolicy
  def index?
    user.admin? || user.user?
  end
end
```

Now implement authorization in blog controller file `app/controlers/api/v1/blogs_controller.rb` and add following codes:

```ruby
before_action :authorization_request
```
and

```ruby
private

def authorization_request
  authorize @current_user, policy_class: BlogPolicy
end
```

Here, we authorize `Api::V1::BlogsController` for current user with `BlogPolicy`. Based on `BlogPolicy`,
current user admin or normal user can see the API result.

Now, blog controller file `app/controlers/api/v1/blogs_controller.rb` looks like below:

```ruby
class Api::V1::BlogsController < ApplicationController
  before_action :authorization_request

  def index
    data = "Hello Sanda"
    render_json_response(:ok, I18n.t("data.success.fetched"), data)
  end

  private

  def authorization_request
    authorize @current_user, policy_class: BlogPolicy
  end
end
```

Nice! Now we have a route `/api/v1/blogs` that is only accessible with a valid bearer token.

### Test Protected Routes

If you have already created a user, you need his accessToken first. You can use the admin user or create a new user and then log in and note their bearer token. To create or authenticate a user, check the documentation in the beginning.

To create a new user, you can place a curl request or use tools like Postman, Insomnia or HTTPie. Here is a quick example using curl.

```shell
curl --location 'http://localhost:3000/api/v1/blogs' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjozLCJleHAiOjE3NTM3NzE1NDJ9.5ncIDT8oo0uEhBOwJLaIYjPCcnV4cMCCsMeICMVI8t0' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json'
```

Great! Now we have our users. Let's login as this new user using curl (You can use tools like Postman, Insomnia, or HTTPie)

```shell
curl --location 'localhost:3000/api/v1/registration' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json' \
--data-raw '{
    "user": {
        "name": "Sanda User ",
        "email": "user2@sanda.project",
        "password": "sanda-user-123"
    }
}'
```

Now you have this user's accessToken in the response, as shown below. Note it.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0LCJleHAiOjE3NTM3NzUyMjh9.jq_eTPEVJ8OjIY6OGvezPPRlyh4IITENvoaEHTWjfBU"
  }
}
```

The bearer token for this user is `eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0LCJleHAiOjE3NTM3NzUyMjh9.jq_eTPEVJ8OjIY6OGvezPPRlyh4IITENvoaEHTWjfBU`

Now let's test our protected route. Add this bearer token in your PostMan/Insomnia/HTTPie or Curl call and make a `HTTP GET` request to our newly created protected route `http://localhost:3000/api/v1/blogs`. Here's an example call with curl

```shell
curl --location 'http://localhost:3000/api/v1/blogs' \
--header 'Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0LCJleHAiOjE3NTM3NzUyMjh9.jq_eTPEVJ8OjIY6OGvezPPRlyh4IITENvoaEHTWjfBU' \
--header 'Accept: application/json' \
--header 'Content-Type: application/json'
```

The response will be something like this.

```json
{
  "status": 200,
  "message": "Successfully data fetched",
  "data": "Hello Sanda"
}
```

Great! you have learned how to create your protected API endpoint using Ruby on Rails and Sanda!

Now you know everything to start creating your next big API project with Ruby on Rails our powerful boilerplate project called Sanda. Enjoy!
