# Network

A simple HTTP library for Client-Server communication.


## Success Criteria

1. Stable
2. Abstract Public APIs
3. 90% code coverage
4. Unit tests runtime has to be <= 200 milliseconds


## Use Cases

1. Given a network service
    when a request is received
    then the request is sent to server.
    
2. Given a network service
    when a response is received from server
    then the response is returned to the consumer.
    
3. Given a network service
    when an error occured during the network call
    then the error is returned with HTTP status code to the consumer.
