/*
 * Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

module io.ballerina.stdlib.stan.runtime {
    requires jnats;
    requires java.nats.streaming;
    requires io.ballerina.runtime;
    requires org.slf4j;
    requires io.ballerina.lang;
    exports org.ballerinalang.nats.connection;
    exports org.ballerinalang.nats.observability;
    exports org.ballerinalang.nats.streaming;
    exports org.ballerinalang.nats.streaming.consumer;
    exports org.ballerinalang.nats.streaming.producer;
    exports org.ballerinalang.nats.streaming.message;
}
