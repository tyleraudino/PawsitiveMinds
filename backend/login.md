# Logging In/Registering

## Registering

To register a user, send a POST request to the `/user/register` endpoint with the following JSON body:

```json
{
    "user_id": "YOUR_USER_ID",
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
    "user_id": "YOUR_USER_ID",
    "password": "YOUR_PASSWORD"
}
```

On success, the endpoint returns a 200 status code and the following JSON body:
```json
{
    "message": "Login successful!",
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