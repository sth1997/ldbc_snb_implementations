package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3;

import com.ldbc.driver.DbException;
import com.ldbc.impls.workloads.ldbc.snb.BaseDbConnectionState;
import org.apache.commons.io.IOUtils;
import org.apache.commons.lang.StringUtils;
import  org.apache.tinkerpop.gremlin.driver.Client;
import  org.apache.tinkerpop.gremlin.driver.Cluster;
import  org.apache.tinkerpop.gremlin.driver.MessageSerializer;
import  org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0;
import org.apache.tinkerpop.gremlin.driver.ser.Serializers;

import  java.util.HashMap;
import java.util.List;
import  java.util.Map;

import java.io.IOException;
import java.util.stream.Collectors;

public class Tinkerpop3DbConnectionState extends BaseDbConnectionState<Tinkerpop3QueryStore>{

    protected final Cluster cluster;
    protected final Client client;
    public Tinkerpop3DbConnectionState(Map<String, String> properties, Tinkerpop3QueryStore queryStore) {
        super(properties, queryStore);
        String endPoint = properties.get("endpoint");
        String strarray[] = endPoint.split(":");
        String ip = strarray[0];
        String port = strarray[1];
        String user = properties.get("user");
        String password = properties.get("password");

        MessageSerializer serializer = Serializers.GRYO_V1D0.simpleInstance();
        Map<String, Object> serializerConfig = new HashMap<String, Object>();
        List<String> customSerializerClassList;
        try {
            customSerializerClassList = IOUtils.readLines(
                    Thread.currentThread().getContextClassLoader().getResourceAsStream("serializer.custom.config"),
                    "utf-8").stream().filter(StringUtils::isNotEmpty).collect(Collectors.toList());
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        serializerConfig.put("custom", customSerializerClassList);
        serializer.configure(serializerConfig, null);

        Cluster.Builder  builder  =  Cluster.build();
        builder.addContactPoint(ip);
        builder.port(Integer.parseInt(port));
        builder.credentials(user,  password);
        builder.serializer(serializer);
        cluster  =  builder.create();
        client  =  cluster.connect();
    }

    public Client getClient() throws DbException {
        return client;
    }

    @Override
    public void close() throws IOException {
        client.close();
        cluster.close();
    }
}
