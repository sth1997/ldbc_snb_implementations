#!/bin/bash

java -cp target/tinkerpop-0.0.1-SNAPSHOT-jar-with-dependencies.jar com.ldbc.impls.workloads.ldbc.snb.tinkerpop.TinkerPopLoader -batchSize 50000 -input ../../ldbc_snb_datagen/social_network
