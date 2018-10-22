package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.tinkerpop.gremlin.java.GremlinPipeline;
import org.apache.commons.cli.*;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.tinkerpop.gremlin.groovy.jsr223.GremlinGroovyScriptEngine;
import org.apache.tinkerpop.gremlin.process.traversal.P;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversal;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.structure.T;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.apache.tinkerpop.gremlin.structure.VertexProperty;
import org.apache.tinkerpop.gremlin.structure.io.IoCore;
import org.apache.tinkerpop.gremlin.tinkergraph.structure.TinkerGraph;
import org.apache.tinkerpop.gremlin.util.Gremlin;
import org.janusgraph.core.Cardinality;
import org.janusgraph.core.JanusGraph;
import org.janusgraph.core.JanusGraphFactory;
import org.opencypher.gremlin.translation.TranslationFacade;

import javax.script.Bindings;
import javax.script.ScriptEngine;
import javax.script.ScriptException;
import javax.sound.midi.SysexMessage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.NoSuchFileException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class TinkerPopTrial {

    private static void runQuery(GraphTraversalSource g, String cypher) throws ScriptException {
        String cypherWithIID = cypher.replaceAll("id:", "iid:").replaceAll("\\.id", "\\.iid");
        String cypherWithIIDWithoutToInteger = cypherWithIID;
        Pattern p = Pattern.compile("toInteger\\((.*)\\)");
        Matcher m = p.matcher(cypherWithIIDWithoutToInteger);
        if (m.find()) {
            cypherWithIIDWithoutToInteger = m.replaceAll("$1");
        }
        TranslationFacade cfog = new TranslationFacade();
        System.out.println(cypherWithIIDWithoutToInteger);
        String gremlin = cfog.toGremlinGroovy(cypherWithIIDWithoutToInteger);
        System.out.println(gremlin);
        ScriptEngine engine = new GremlinGroovyScriptEngine();
        Bindings bindings = engine.createBindings();
        bindings.put("g", g);
        Object o = engine.eval(gremlin, bindings);
        GraphTraversal<Vertex, Map<Object, Object>> a = (GraphTraversal<Vertex, Map<Object, Object>>) o;
        while (a.hasNext()) {
            System.out.println("---");
            System.out.println(a.next().toString());
        }
    }

    public static void main(String[] args) throws IOException, ConfigurationException {
        final PropertiesConfiguration conf = new PropertiesConfiguration(new File("tinkerpop.properties"));
//        conf.addProperty("gremlin.graph", "org.janusgraph.core.JanusGraphFactory");
//        conf.addProperty("storage.backend", "inmemory");
//        conf.addProperty("storage.directory", "data/graph");
        try (JanusGraph graph = JanusGraphFactory.open(conf)) {
//        try (TinkerGraph graph = TinkerGraph.open(conf)) {
            if (conf.getString("storage.backend").equals("inmemory")) {
                graph.io(IoCore.gryo()).readGraph("sftiny_janus.gryo");
            }
            GraphTraversalSource g = graph.traversal();
//            GraphTraversal<Vertex, Vertex> aa = g.V().hasLabel("Person");
//            while (aa.hasNext()) {
//                Vertex v = aa.next();
//                System.out.println(v.property("iid"));
//                Iterator<VertexProperty<String>> vpIt = v.properties("language");
//                while(vpIt.hasNext()){
//                    System.out.println(vpIt.next());
//                }
//            }
            String cypher = new String(Files.readAllBytes(Paths.get("query.txt")));
            String cypher2 = "MATCH (p:Person )-[:KNOWS]-(friend:Person)\n" +
                    "RETURN friend\n" +
                    "ORDER BY p.id, friend.id";
            String cypher3 = "MATCH (p:Person {id:8796093022246})\n" +
                    "RETURN p";
            runQuery(g, cypher);
            runQuery(g, cypher2);
            runQuery(g, cypher3);
            Iterator<Vertex> it = g.V().hasLabel("Person").has("iid", P.eq(8796093022246L));
            while (it.hasNext()) {
                Vertex a = it.next();
                System.out.println(a);
                Iterator<VertexProperty<String>> vpIt = a.properties("language");
                while (vpIt.hasNext()) {
                    VertexProperty<String> vp = vpIt.next();
                    System.out.print(vp.value() + " ");
                }
                System.out.println();
            }
        } catch (Exception e) {
            System.out.println("Exception: " + e);
            e.printStackTrace();
        }
    }
}