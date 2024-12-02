# Logging In/Registering

## Registering

To register a user, send a POST request to the `/user/register` endpoint with the following JSON body:

```json
{
    "username": "YOUR_USERNAME",
    "first_name": "YOUR_FIRST_NAME",
    "last_name": "YOUR_LAST_NAME",
    "email": "YOUR_EMAIL",
    "password": "YOUR_PASSWORD"
}
```

On success, the endpoint returns a 200 status code and the following JSON body:
```json
{
    "message": "User registered successfully.",
    "token": "YOUR_TOKEN"
}
```

## Login

To log in, send a POST request to the `/user/login` endpoint with the following JSON body:

```json
{
    "username": "YOUR_USERNAME",
    "password": "YOUR_PASSWORD"
}
```

On success, the endpoint returns a 200 status code and the following JSON body:
```json
{
    "message": "Login successful!",
    "first_name": "YOUR_FIRST_NAME",
    "last_name": "YOUR_LAST_NAME",
    "email": "YOUR_EMAIL",
    "token": "YOUR_TOKEN"
}
```

## After Registering/Logging In

*This is not actually implemented yet, but this is how it will work.*

After registering/logging in, you must include the token in the *header* of all subsequent requests. The header should look like this
```json
{
    "Authorization": "Bearer YOUR_TOKEN"
}
```

## Changing Password

To change your password, send a POST request to the `/user/change_password` endpoint with the following JSON:

```json
{
    "password": "YOUR_NEW_PASSWORD"
}
```

Meanwhile, the token should be included in the header of the request.
```json
{
    "Authorization": "Bearer YOUR_TOKEN"
}
```

## Changing Email

To change your email, send a POST request to the `/user/change_email` endpoint with the following JSON:

```json
{
    "email": "YOUR_NEW_EMAIL"
}
```

The token should be included in the header of the request.

## Change Username

To change your username, send a POST request to the `/user/change_username` endpoint with the following JSON:

```json
{
    "username": "YOUR_NEW_USER_ID"
}
```

The token should be included in the header of the request.

## Deleting User

To delete the currently logged in user, send a DELETE request to the `/user/delete` endpoint. The token should be included in the header of the request.
