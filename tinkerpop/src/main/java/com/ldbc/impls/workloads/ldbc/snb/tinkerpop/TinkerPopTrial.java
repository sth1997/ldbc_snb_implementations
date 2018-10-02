package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import org.apache.commons.cli.*;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversal;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.structure.T;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.apache.tinkerpop.gremlin.structure.VertexProperty;
import org.apache.tinkerpop.gremlin.structure.io.IoCore;
import org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerGraph;
import org.janusgraph.core.Cardinality;
import org.janusgraph.core.JanusGraph;
import org.janusgraph.core.JanusGraphFactory;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TinkerPopTrial {

    private static final Logger logger =
            Logger.getLogger(TinkerPopTrial.class.getName());

    private static final long TX_MAX_RETRIES = 1000;


    public static void main(String[] args) throws IOException {
        final PropertiesConfiguration conf = new PropertiesConfiguration();
        conf.addProperty("gremlin.graph", "org.janusgraph.core.JanusGraphFactory");
        conf.addProperty("storage.backend", "inmemory");
        try (JanusGraph graph = JanusGraphFactory.open(conf)) {
//        try (TinkerGraph graph = TinkerGraph.open(conf)) {
            graph.io(IoCore.gryo()).readGraph("sftiny_janus.gyro");
            GraphTraversalSource g = graph.traversal();
            GraphTraversal<Vertex, Vertex> a = g.V().hasLabel("person");
            while (a.hasNext()) {
                Vertex v = a.next();
                v.property("language");
                System.out.println(v.toString() + "\n---------------");
//                System.out.println(v.property("iid"));
//                System.out.println(v.property("language"));
//                g.V().hasLabel("person").
            }
        } catch (Exception e) {
            System.out.println("Exception: " + e);
            e.printStackTrace();
        }
    }
}