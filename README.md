# Network

A simple HTTP library for Client-Server communication.


## Success Criteria

1. Stable Library
    > Adheres to **Stable Dependency Principle**
2. Abstract Public APIs
    > Adheres to **Stable Abstraction Principle**
3. 90% code coverage
4. Unit tests runtime has to be <= 200 milliseconds
5. Instrumentation tests runtime has to be <= 2 seconds


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
    
4. Given a network service
    when a request is received
    then addition info is added to the request before it send to the server
