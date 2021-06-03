// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.'string;
import ballerina/lang.runtime as runtime;
import ballerina/log;
import ballerina/test;

const CONSUMER_SERVICE_SUBJECT_NAME = "nats-streaming-consumer-service";
const ACK_SUBJECT_NAME = "nats-streaming-ack";
const DUMMY_SUBJECT_NAME = "nats-streaming-dummy";
const INVALID_SUBJECT_NAME = "nats-streaming-invalid";
const SERVICE_NO_CONFIG_NAME = "nats-streaming-service-no-config";
const QUEUE_SUBJECT_NAME = "nats-streaming-queue";
const DURABLE_SUBJECT_NAME = "nats-streaming-queue";

string receivedConsumerMessage = "";
string receivedAckMessage = "";
string noConfigServiceReceivedMessage = "";
string receivedQueueMessage = "";
string receivedDurableMessage = "";

boolean ackNegativeFlag = false;
boolean invalidServiceFlag = true;

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerService() {
    string message = "Testing Consumer Service";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(consumerService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(),
                                                       subject: CONSUMER_SERVICE_SUBJECT_NAME});
    runtime:sleep(5);
    test:assertEquals(receivedConsumerMessage, message, msg = "Message received does not match.");
    checkpanic newClient.close();
}

@test:Config {
    dependsOn: [testConnectionWithMultipleServers],
    groups: ["nats-streaming"]
}
public function testConsumerServiceWithMultipleServers() {
    string message = "Testing Multiple Server Consumer Service";
    Listener sub = checkpanic new([DEFAULT_URL, DEFAULT_URL]);
    Client newClient = checkpanic new([DEFAULT_URL, DEFAULT_URL]);
    checkpanic sub.attach(consumerService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(),
                                                       subject: CONSUMER_SERVICE_SUBJECT_NAME });
    runtime:sleep(5);
    test:assertEquals(receivedConsumerMessage, message, msg = "Message received does not match.");
    checkpanic newClient.close();
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerServiceWithAck() {
    string message = "Testing Consumer Service With Acknowledgement";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(ackService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: ACK_SUBJECT_NAME});
    runtime:sleep(5);
    test:assertEquals(receivedAckMessage, message, msg = "Message received does not match.");
    checkpanic newClient.close();
    checkpanic sub.close();
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerServiceWithAckNegative() {
    string message = "Testing Consumer Service With Acknowledgement Negative";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(ackNegativeService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: ACK_SUBJECT_NAME});
    runtime:sleep(5);
    test:assertTrue(ackNegativeFlag, msg = "Manual acknowledgement did not fail.");
    checkpanic newClient.close();
    checkpanic sub.close();
}

@test:Config {
    groups: ["nats-streaming"]
}
public function testInvalidConsumerService() {
    string message = "Testing Invalid Consumer Service";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(invalidService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: INVALID_SUBJECT_NAME});
    runtime:sleep(5);
    test:assertTrue(invalidServiceFlag, msg = "Message received does not match.");
    checkpanic newClient.close();
    checkpanic sub.close();
}


@test:Config {
   groups: ["nats-streaming"]
}
public function testConsumerServiceWithQueue() {
    string message = "Testing Consumer Service With Queue";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(queueService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: QUEUE_SUBJECT_NAME});
    runtime:sleep(5);
    test:assertEquals(receivedQueueMessage, message, msg = "Message received does not match.");
    checkpanic newClient.close();
    checkpanic sub.close();
}

@test:Config {
   groups: ["nats-streaming"]
}
public function testConsumerServiceWithDurable() {
    string message = "Testing Consumer Service With Durable";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(durableService);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: DURABLE_SUBJECT_NAME });
    runtime:sleep(5);
    test:assertEquals(receivedDurableMessage, message, msg = "Message received does not match.");
    checkpanic newClient.close();
    checkpanic sub.close();
}

@test:Config {
    groups: ["nats-streaming"]
}
public isolated function testConsumerWithToken() {
    Tokens myToken = { token: "MyToken" };
    Listener|error? sub = new("nats://localhost:4223", auth = myToken);
    if !(sub is Listener) {
        test:assertFail("Connecting to server with token failed.");
    }
}

@test:Config {
    groups: ["nats-streaming"]
}
public isolated function testConsumerWithCredentials() {
    Credentials myCredentials = {
        username: "ballerina",
        password: "ballerina123"
    };
    Listener|error? sub = new("nats://localhost:4224", auth = myCredentials);
    if !(sub is Listener) {
        test:assertFail("Connecting to server with credentials failed.");
    }
}

@test:Config {
    groups: ["nats-streaming"]
}
public isolated function testConsumerWithTokenNegative() {
    Tokens myToken = { token: "IncorrectToken" };
    Listener|error? sub = new("nats://localhost:4223", auth = myToken);
    if !(sub is error) {
        test:assertFail("Expected failure for connecting to server with invalid token.");
    }
}

@test:Config {
    groups: ["nats-streaming"]
}
public isolated function testConsumerWithCredentialsNegative() {
    Credentials myCredentials = {
        username: "ballerina",
        password: "IncorrectPassword"
    };
    Listener|error? sub = new("nats://localhost:4224", auth = myCredentials);
    if !(sub is error) {
        test:assertFail("Expected failure for connecting to server with invalid credentials.");
    }
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerServiceDetach1() {
    Listener sub = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(dummyService);
    checkpanic sub.'start();
    error? detachResult = sub.detach(dummyService);
    if (detachResult is error) {
        test:assertFail("Detaching service failed.");
    }
    error? stopResult = sub.immediateStop();
    if (stopResult is error) {
        test:assertFail("Stopping listener failed.");
    }
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerServiceDetach2() {
    Listener sub = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(dummyService);
    checkpanic sub.'start();
    error? detachResult = sub.detach(dummyService);
    if (detachResult is error) {
        test:assertFail("Detaching service failed.");
    }
    error? stopResult = sub.gracefulStop();
    if (stopResult is error) {
        test:assertFail("Stopping listener failed.");
    }
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testConsumerServiceDetach3() {
    Listener sub = checkpanic new(DEFAULT_URL);
    checkpanic sub.'start();
    error? detachResult = sub.detach(dummyService);
    if (detachResult is error) {
        test:assertFail("Detaching service failed.");
    }
    error? stopResult = sub.gracefulStop();
    if (stopResult is error) {
        test:assertFail("Stopping listener failed.");
    }
}

@test:Config {
    dependsOn: [testProducer],
    groups: ["nats-streaming"]
}
public function testNoConfigConsumerService() {
    string message = "Testing No Subject Consumer Service";
    Listener sub = checkpanic new(DEFAULT_URL);
    Client newClient = checkpanic new(DEFAULT_URL);
    checkpanic sub.attach(noConfigService, SERVICE_NO_CONFIG_NAME);
    checkpanic sub.'start();
    string id = checkpanic newClient->publishMessage({ content: message.toBytes(), subject: SERVICE_NO_CONFIG_NAME });
    runtime:sleep(5);
    test:assertEquals(noConfigServiceReceivedMessage, message, msg = "Message received does not match.");

    error? attachResult = sub.attach(noConfigService);
    if !(attachResult is error){
        test:assertFail("Expected failure to attach did not fail.");
    }
    checkpanic newClient.close();
    checkpanic sub.close();
}

Service consumerService =
@ServiceConfig {
    subject: CONSUMER_SERVICE_SUBJECT_NAME
}
service object {
    remote function onMessage(Message msg) {
        string|error messageContent = 'string:fromBytes(msg.content);
        if (messageContent is string) {
            receivedConsumerMessage = messageContent;
            log:printInfo("Message Received: " + receivedConsumerMessage);
        }
    }
};

Service ackService =
@ServiceConfig {
    subject: ACK_SUBJECT_NAME,
    autoAck: false
}
service object {
    remote function onMessage(Message msg, Caller caller) {
        string|error messageContent = 'string:fromBytes(msg.content);
        if (messageContent is string) {
            receivedAckMessage = messageContent;
            log:printInfo("Message Received: " + receivedAckMessage);
        }
        checkpanic caller->ack();
    }
};

Service ackNegativeService =
@ServiceConfig {
    subject: ACK_SUBJECT_NAME
}
service object {
    remote function onMessage(Message msg, Caller caller) {
        string|error messageContent = 'string:fromBytes(msg.content);
        if (messageContent is string) {
            receivedAckMessage = messageContent;
            log:printInfo("Message Received: " + receivedAckMessage);
        }
        Error? ackResult = caller->ack();
        if (ackResult is error){
            ackNegativeFlag = true;
        }
    }
};

Service dummyService =
@ServiceConfig {
    subject: DUMMY_SUBJECT_NAME
}
service object {
    remote isolated function onMessage(Message msg, Caller caller) {
    }
};

Service queueService =
@ServiceConfig {
    subject: QUEUE_SUBJECT_NAME,
    queueName: "testQueue"
}
service object {
    remote function onMessage(Message msg, Caller caller) {
        string|error messageContent = 'string:fromBytes(msg.content);
        if (messageContent is string) {
            receivedQueueMessage = messageContent;
            log:printInfo("Message Received: " + receivedQueueMessage);
        }
    }
};

Service durableService =
@ServiceConfig {
    subject: DURABLE_SUBJECT_NAME,
    durableName: "testDurable"
}
service object {
    remote function onMessage(Message msg, Caller caller) {
        string|error messageContent = 'string:fromBytes(msg.content);
        if (messageContent is string) {
            receivedDurableMessage = messageContent;
            log:printInfo("Message Received: " + receivedDurableMessage);
        }
    }
};

Service noConfigService =
service object {
    remote function onMessage(Message msg, Caller caller) {
        string|error messageContent = 'string:fromBytes(msg.content);
            if (messageContent is string) {
                noConfigServiceReceivedMessage = messageContent;
                log:printInfo("Message Received: " + noConfigServiceReceivedMessage);
            }
    }
};

Service invalidService =
@ServiceConfig {
    subject: INVALID_SUBJECT_NAME
}
service object {
    remote function onMessage(Message msg, Caller caller, string invalidArgument) {
        invalidServiceFlag = false;
    }
};
