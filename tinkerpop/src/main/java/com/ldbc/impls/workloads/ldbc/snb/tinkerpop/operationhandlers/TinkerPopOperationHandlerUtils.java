package com.ldbc.impls.workloads.ldbc.snb.tinkerpop.operationhandlers;

import org.apache.tinkerpop.gremlin.groovy.jsr223.GremlinGroovyScriptEngine;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversal;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.opencypher.gremlin.translation.TranslationFacade;

import javax.script.Bindings;
import javax.script.ScriptEngine;
import javax.script.ScriptException;
import java.util.Iterator;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public abstract class TinkerPopOperationHandlerUtils {
    static String convertCypherQuery(String cypherQuery){
        String cypherWithIID = cypherQuery.replaceAll("id:", "iid:").replaceAll("\\.id", "\\.iid");
        Pattern p = Pattern.compile("toInteger\\((.*)\\)");
        Matcher m = p.matcher(cypherWithIID);
        if (m.find()) {
            return m.replaceAll("$1");
        }
        return cypherWithIID;
    }

    static Iterator<Map<String, Object>> runQuery(GraphTraversalSource traversalSource, String preprocessCypherQuery) throws ScriptException {
        TranslationFacade cfog = new TranslationFacade();
        String gremlin = cfog.toGremlinGroovy(preprocessCypherQuery);
        ScriptEngine engine = new GremlinGroovyScriptEngine();
        Bindings bindings = engine.createBindings();
        bindings.put("g", traversalSource);
        return (GraphTraversal<Vertex, Map<String, Object>>) engine.eval(gremlin, bindings);
    }
}
