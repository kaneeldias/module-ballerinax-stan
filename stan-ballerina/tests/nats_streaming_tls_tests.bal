import ballerina/test;
import ballerina/log;

@test:Config {
    groups: ["nats-streaming"]
}
isolated function testTlsConnection1() {
    SecureSocket secured = {
        cert: {
            path: "tests/certs/cert.pfx",
            password: "password"
        },
        protocol: {
            name: TLS
        }
    };
    // TODO: Resolve TLS issues
    Client|Error newClient = new("nats://localhost:4225", secureSocket = secured);
    if (newClient is error) {
        log:printInfo("Error: " + newClient.message());
        test:assertFail("NATS Connection initialization with TLS failed.");
    }
}

@test:Config {
    groups: ["nats-streaming"]
}
isolated function testTlsConnection2() {
    SecureSocket secured = {
        cert: {
            path: "tests/certs/cert.pfx",
            password: "password"
        },
        key: {
            path: "tests/certs/cert.pfx",
            password: "password"
        },
         protocol: {
            name: TLS
         }
    };
    Client|Error newClient = new("nats://localhost:4225", secureSocket = secured);
    if (newClient is Client) {
        test:assertFail("Error expected for NATS Connection initialization with TLS.");
    }
}

@test:Config {
    groups: ["nats-streaming"]
}
isolated function testTlsConnection3() {
    SecureSocket secured = {
        cert: {
            path: "tests/certs/cert.pfx",
            password: "password"
        }
    };
    // TODO: Resolve TLS issues
    Client|Error newClient = new("nats://localhost:4225", secureSocket = secured);
    if (newClient is error) {
        log:printInfo("Error: " + newClient.message());
        test:assertFail("NATS Connection initialization with TLS failed.");
    }
}
