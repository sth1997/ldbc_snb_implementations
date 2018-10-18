package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.tinkerpop.gremlin.java.GremlinPipeline;
import org.apache.commons.cli.*;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.tinkerpop.gremlin.groovy.jsr223.GremlinGroovyScriptEngine;
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
import javax.sound.midi.SysexMessage;
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

    private static final Logger logger =
            Logger.getLogger(TinkerPopTrial.class.getName());

    private static final long TX_MAX_RETRIES = 1000;


    public static void main(String[] args) throws IOException {
        final PropertiesConfiguration conf = new PropertiesConfiguration();
        conf.addProperty("gremlin.graph", "org.janusgraph.core.JanusGraphFactory");
        conf.addProperty("storage.backend", "berkeleyje");
        conf.addProperty("storage.directory", "dataaa/graph");
        try (JanusGraph graph = JanusGraphFactory.open(conf)) {
//        try (TinkerGraph graph = TinkerGraph.open(conf)) {
//            graph.io(IoCore.gryo()).readGraph("sftiny_janus.gryo");
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
            String cypher = "MATCH path = allShortestPaths((person1:Person {id:32985348833679})-[:KNOWS*..15]-(person2:Person {id:2199023256862}))\n" +
                    "WITH nodes(path) AS pathNodes\n" +
                    "RETURN\n" +
                    "  extract(n IN pathNodes | n.id) AS personIdsInPath,\n" +
                    "  reduce(weight=0.0, idx IN range(1,size(pathNodes)-1) | extract(prev IN [pathNodes[idx-1]] | extract(curr IN [pathNodes[idx]] | weight + length((curr)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Post)-[:HAS_CREATOR]->(prev))*1.0 + length((prev)<-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]->(:Post)-[:HAS_CREATOR]->(curr))*1.0 + length((prev)-[:HAS_CREATOR]-(:Comment)-[:REPLY_OF]-(:Comment)-[:HAS_CREATOR]-(curr))*0.5) )[0][0]) AS pathWight\n" +
                    "ORDER BY pathWight DESC";
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
            GraphTraversal<Vertex, Map<String, Object>> a = (GraphTraversal<Vertex, Map<String, Object>>) o;
            while (a.hasNext()) {
                System.out.println("---");
                System.out.println(a.next());
            }
        } catch (Exception e) {
            System.out.println("Exception: " + e);
            e.printStackTrace();
        }
    }
}