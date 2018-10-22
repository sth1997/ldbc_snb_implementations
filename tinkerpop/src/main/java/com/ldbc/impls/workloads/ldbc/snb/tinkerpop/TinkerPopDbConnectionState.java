package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.ldbc.driver.DbException;
import com.ldbc.impls.workloads.ldbc.snb.BaseDbConnectionState;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerGraph;
import org.janusgraph.core.JanusGraphFactory;

import java.io.IOException;
import java.util.Map;

public class TinkerPopDbConnectionState extends BaseDbConnectionState<TinkerPopQueryStore> {

    protected final Graph graph;

    public TinkerPopDbConnectionState(Map<String, String> properties, TinkerPopQueryStore store) {
        super(properties, store);
        String graphType = properties.get("graphType");
        if (graphType.equals("tinkerpop")) {
            graph = TinkerGraph.open();
        } else if (graphType.equals("janus")){
            final PropertiesConfiguration conf = new PropertiesConfiguration();
            conf.addProperty("gremlin.graph", "org.janusgraph.core.JanusGraphFactory");
            conf.addProperty("storage.backend", properties.get("storage.backend"));
            conf.addProperty("storage.directory", properties.getOrDefault("storage.directory","inemmoryBackend?"));
            graph = JanusGraphFactory.open(conf);
        } else {
            throw new IllegalArgumentException(properties.toString());
        }
    }

    public GraphTraversalSource getTraversal() throws DbException {
        return graph.traversal();
    }

    @Override
    public void close() throws IOException {
        try {
            graph.close();
        } catch (Exception e) {
            throw new IOException(e);
        }
    }

}
