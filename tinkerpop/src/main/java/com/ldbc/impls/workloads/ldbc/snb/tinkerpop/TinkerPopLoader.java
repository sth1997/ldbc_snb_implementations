package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.ldbc.impls.workloads.ldbc.snb.converter.Converter;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop.converter.TinkerPopConverter;
import org.apache.commons.cli.*;
import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.structure.T;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.apache.tinkerpop.gremlin.structure.VertexProperty;
import org.apache.tinkerpop.gremlin.structure.io.IoCore;
import org.janusgraph.core.*;
import org.janusgraph.core.schema.SchemaAction;
import org.janusgraph.graphdb.database.management.ManagementSystem;

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

public class TinkerPopLoader {

    private static final Logger logger =
            Logger.getLogger(TinkerPopLoader.class.getName());

    private static final long TX_MAX_RETRIES = 1000;

    private static void loadVertices(Graph graph, Path filePath,
                                     boolean printLoadingDots, int batchSize, long progReportPeriod)
            throws IOException, java.text.ParseException {

        String[] colNames = null;
        boolean firstLine = true;
        Map<Object, Object> propertiesMap;
        SimpleDateFormat birthdayDateFormat = new SimpleDateFormat("yyyy-MM-dd");
        birthdayDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        SimpleDateFormat creationDateDateFormat =
                new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        creationDateDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        String fileNameParts[] = filePath.getFileName().toString().split("_");
        String entityName = fileNameParts[0].substring(0, 1).toUpperCase() + fileNameParts[0].substring(1);

        List<String> lines = Files.readAllLines(filePath);
        colNames = lines.get(0).split("\\|");
        long lineCount = 0;
        Converter converter = new TinkerPopConverter();

        // For progress reporting
        long startTime = System.currentTimeMillis();
        long nextProgReportTime = startTime + progReportPeriod * 1000;
        long lastLineCount = 0;

        for (int i = 1; i < lines.size(); ++i) {
            String line = lines.get(i);

            String[] colVals = line.split("\\|");
            propertiesMap = new HashMap<>();

            for (int j = 0; j < colVals.length; ++j) {
                if (colNames[j].equals("id")) {
                    propertiesMap.put("iid", Long.parseLong(colVals[j]));
                } else if (colNames[j].equals("birthday")) {
                    Date birthDate = birthdayDateFormat.parse(colVals[j]);
                    propertiesMap.put(colNames[j], Long.parseLong(converter.convertDate(birthDate)));
                } else if (colNames[j].equals("creationDate")) {
                    Date creationDate = creationDateDateFormat.parse(colVals[j]);
                    propertiesMap.put(colNames[j], Long.parseLong(converter.convertDateTime(creationDate)));
                } else {
                    propertiesMap.put(colNames[j], colVals[j]);
                }
            }

            propertiesMap.put(T.label, entityName);

            List<Object> keyValues = new ArrayList<>();
            propertiesMap.forEach((key, val) -> {
                keyValues.add(key);
                keyValues.add(val);
            });

            graph.addVertex(keyValues.toArray());

            lineCount++;
        }

        try {
            if (graph.features().graph().supportsTransactions()) {
                graph.tx().commit();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }


        if (printLoadingDots &&
                (System.currentTimeMillis() > nextProgReportTime)) {
            long timeElapsed = System.currentTimeMillis() - startTime;
            long linesLoaded = lineCount - lastLineCount;
            System.out.println(String.format(
                    "Time Elapsed: %03dm.%02ds, Lines Loaded: +%d",
                    (timeElapsed / 1000) / 60, (timeElapsed / 1000) % 60, linesLoaded));
            nextProgReportTime += progReportPeriod * 1000;
            lastLineCount = lineCount;
        }
    }

    private static void loadProperties(Graph graph, Path filePath,
                                       boolean printLoadingDots, int batchSize, long progReportPeriod)
            throws IOException {
        long count = 0;
        String[] colNames = null;
        boolean firstLine = true;
        String fileNameParts[] = filePath.getFileName().toString().split("_");
        String entityName = fileNameParts[0].substring(0, 1).toUpperCase() + fileNameParts[0].substring(1);

        List<String> lines = Files.readAllLines(filePath);
        colNames = lines.get(0).split("\\|");
        long lineCount = 0;

        // For progress reporting
        long startTime = System.currentTimeMillis();
        long nextProgReportTime = startTime + progReportPeriod * 1000;
        long lastLineCount = 0;
        Vertex vertex = null;
        String previousId = "";

        for (int i = 1; i < lines.size(); ++i) {
            String line = lines.get(i);

            String[] colVals = line.split("\\|");

            if (!colVals[0].equals(previousId)) {
                GraphTraversalSource g = graph.traversal();
                vertex =
                        g.V().has("iid", Long.parseLong(colVals[0])).next();
                previousId = colVals[0];
            }

            for (int j = 1; j < colVals.length; ++j) {
                vertex.property(VertexProperty.Cardinality.list, colNames[j],
                        colVals[j]);
            }

            lineCount++;
        }

        try {
            if (graph.features().graph().supportsTransactions()) {
                graph.tx().commit();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (printLoadingDots &&
                (System.currentTimeMillis() > nextProgReportTime)) {
            long timeElapsed = System.currentTimeMillis() - startTime;
            long linesLoaded = lineCount - lastLineCount;
            System.out.println(String.format(
                    "Time Elapsed: %03dm.%02ds, Lines Loaded: +%d",
                    (timeElapsed / 1000) / 60, (timeElapsed / 1000) % 60, linesLoaded));
            nextProgReportTime += progReportPeriod * 1000;
            lastLineCount = lineCount;
        }
    }

    private static void loadEdges(Graph graph, Path filePath, boolean undirected,
                                  boolean printLoadingDots, int batchSize, long progReportPeriod)
            throws IOException, java.text.ParseException {
        long count = 0;
        String[] colNames = null;
        boolean firstLine = true;
        Map<Object, Object> propertiesMap;
        SimpleDateFormat creationDateDateFormat =
                new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        creationDateDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        SimpleDateFormat joinDateDateFormat =
                new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        joinDateDateFormat.setTimeZone(TimeZone.getTimeZone("GMT"));
        String fileNameParts[] = filePath.getFileName().toString().split("_");
        String v1EntityName = fileNameParts[0].substring(0, 1).toUpperCase() + fileNameParts[0].substring(1);
        String edgeLabel = splitCamelCase(fileNameParts[1]).replaceAll(" ", "_").toUpperCase();
        String v2EntityName = fileNameParts[2].substring(0, 1).toUpperCase() + fileNameParts[2].substring(1);

        List<String> lines = Files.readAllLines(filePath);
        colNames = lines.get(0).split("\\|");
        long lineCount = 0;

        // For progress reporting
        long startTime = System.currentTimeMillis();
        long nextProgReportTime = startTime + progReportPeriod * 1000;
        long lastLineCount = 0;
        Converter converter = new TinkerPopConverter();
        Vertex vertex1 = null;
        String previousId = "";

        for (int i = 1; i < lines.size(); ++i) {
            String line = lines.get(i);

            String[] colVals = line.split("\\|");

            GraphTraversalSource g = graph.traversal();
            if (!colVals[0].equals(previousId)) {
                vertex1 =
                        g.V().has("iid", Long.parseLong(colVals[0])).next();
                previousId = colVals[0];
            }
            Vertex vertex2 =
                    g.V().has("iid", Long.parseLong(colVals[1])).next();

            propertiesMap = new HashMap<>();
            for (int j = 2; j < colVals.length; ++j) {

                if (colNames[j].equals("creationDate") || colNames[j].equals("joinDate")) {

                    Date date = creationDateDateFormat.parse(colVals[j]);
                    propertiesMap.put(colNames[j], Long.parseLong(converter.convertDate(date)));
                } else {
                    propertiesMap.put(colNames[j], colVals[j]);
                }
            }

            List<Object> keyValues = new ArrayList<>();
            propertiesMap.forEach((key, val) -> {
                keyValues.add(key);
                keyValues.add(val);
            });

            vertex1.addEdge(edgeLabel, vertex2, keyValues.toArray());

            if (undirected) {
                vertex2.addEdge(edgeLabel, vertex1, keyValues.toArray());
            }

            lineCount++;

            try {
                if (graph.features().graph().supportsTransactions()) {
                    graph.tx().commit();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (printLoadingDots &&
                    (System.currentTimeMillis() > nextProgReportTime)) {
                long timeElapsed = System.currentTimeMillis() - startTime;
                long linesLoaded = lineCount - lastLineCount;
                System.out.println(String.format(
                        "Time Elapsed: %03dm.%02ds, Lines Loaded: +%d",
                        (timeElapsed / 1000) / 60, (timeElapsed / 1000) % 60, linesLoaded));
                nextProgReportTime += progReportPeriod * 1000;
                lastLineCount = lineCount;
            }
        }
    }

    static String splitCamelCase(String s) {
        return s.replaceAll(
                String.format("%s|%s|%s",
                        "(?<=[A-Z])(?=[A-Z][a-z])",
                        "(?<=[^A-Z])(?=[A-Z])",
                        "(?<=[A-Za-z])(?=[^A-Za-z])"
                ),
                " "
        );
    }

    public static void main(String[] args) throws IOException, ConfigurationException {
        Options options = new Options();
//        options.addOption("C", "locator", true,
//                "IP address of the server server.");
//        options.addOption(null, "backend", true,
//                "Backend storage service: {cassandra|hbase}");
        options.addOption(null, "batchSize", true,
                "Number of nodes/edges to load in a single transaction.");
//        options.addOption(null, "graphName", true,
//                "Name of the graph instance.");
        options.addOption(null, "input", true,
                "Input file directory.");
        options.addOption(null, "progReportPeriod", true,
                "How often, in seconds, to report loading progress (default 10s).");
        options.addOption("h", "help", false,
                "Print usage.");

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        CommandLine cmd = null;
        try {
            cmd = parser.parse(options, args);
        } catch (ParseException ex) {
            logger.log(Level.SEVERE, null, ex);
            return;
        }

        if (cmd.hasOption("h")) {
            formatter.printHelp("TitanGraphLoader", options);
            return;
        }

        int batchSize;
        if (cmd.hasOption("batchSize")) {
            batchSize = Integer.decode(cmd.getOptionValue("batchSize"));
        } else {
            logger.log(Level.SEVERE, "Missing required argument: batchSize");
            return;
        }

        String inputBaseDir;
        if (cmd.hasOption("input")) {
            inputBaseDir = cmd.getOptionValue("input");
        } else {
            logger.log(Level.SEVERE, "Missing required argument: input");
            return;
        }

        long progReportPeriod = 10;
        if (cmd.hasOption("progReportPeriod")) {
            progReportPeriod = Long.decode(cmd.getOptionValue("progReportPeriod"));
        }


        String vertexLabels[] = {
                "person",
                "comment",
                "forum",
                "organisation",
                "place",
                "post",
                "tag",
                "tagclass"
        };

        String edgeLabels[] = {
                "containerOf",
                "hasCreator",
                "hasInterest",
                "hasMember",
                "hasModerator",
                "hasTag",
                "hasType",
                "isLocatedIn",
                "isPartOf",
                "isSubclassOf",
                "knows",
                "likes",
                "replyOf",
                "studyAt",
                "workAt"
        };

        // All property keys with Cardinality.SINGLE
        String singleCardPropKeys[] = {
                "birthday", // person
                "browserUsed", // comment person post
                "classYear", // studyAt
                "content", // comment post
                "creationDate", // comment forum person post knows likes
                "firstName", // person
                "gender", // person
                "imageFile", // post
                "joinDate", // hasMember
                //"language", // post
                "lastName", // person
                "length", // comment post
                "locationIP", // comment person post
                "name", // organisation place tag tagclass
                "title", // forum
                "type", // organisation place
                "url", // organisation place tag tagclass
                "workFrom", // workAt
        };

        // All property keys with Cardinality.LIST
        String listCardPropKeys[] = {
                "email", // person
                "language" // person, post
        };

        /*
         * Explicitly define the graph schema.
         *
         * Note: For unknown reasons, it seems that each modification to the
         * schema must be committed in its own transaction.
         */

        // TODO: Make file list generation programmatic. This method of loading,
        // however, will be far too slow for anything other than the very
        // smallest of SNB graphs, and is therefore quite transient. This will
        // do for now.
        String nodeFiles[] = {
                "person_0_0.csv",
                "comment_0_0.csv",
                "forum_0_0.csv",
                "organisation_0_0.csv",
                "place_0_0.csv",
                "post_0_0.csv",
                "tag_0_0.csv",
                "tagclass_0_0.csv"
        };

        String propertiesFiles[] = {
                "person_email_emailaddress_0_0.csv",
                "person_speaks_language_0_0.csv"
        };

        String edgeFiles[] = {
                "comment_hasCreator_person_0_0.csv",
                "comment_hasTag_tag_0_0.csv",
                "comment_isLocatedIn_place_0_0.csv",
                "comment_replyOf_comment_0_0.csv",
                "comment_replyOf_post_0_0.csv",
                "forum_containerOf_post_0_0.csv",
                "forum_hasMember_person_0_0.csv",
                "forum_hasModerator_person_0_0.csv",
                "forum_hasTag_tag_0_0.csv",
                "organisation_isLocatedIn_place_0_0.csv",
                "person_hasInterest_tag_0_0.csv",
                "person_isLocatedIn_place_0_0.csv",
                "person_knows_person_0_0.csv",
                "person_likes_comment_0_0.csv",
                "person_likes_post_0_0.csv",
                "person_studyAt_organisation_0_0.csv",
                "person_workAt_organisation_0_0.csv",
                "place_isPartOf_place_0_0.csv",
                "post_hasCreator_person_0_0.csv",
                "post_hasTag_tag_0_0.csv",
                "post_isLocatedIn_place_0_0.csv",
                "tag_hasType_tagclass_0_0.csv",
                "tagclass_isSubclassOf_tagclass_0_0.csv"
        };

        final PropertiesConfiguration conf = new PropertiesConfiguration(new File("tinkerpop.properties"));
        System.out.println("Running with properties:" + conf.toString());
//        conf.addProperty("gremlin.graph", "org.janusgraph.core.JanusGraphFactory");
//        conf.addProperty("storage.backend", "inmemory");
//        conf.addProperty("storage.directory", "data/graph");
        try (JanusGraph graph = JanusGraphFactory.open(conf)) {
//        try (TinkerGraph graph = TinkerGraph.open(conf)) {
            if (JanusGraph.class.isInstance(graph)) {
                JanusGraph janusGraph = JanusGraph.class.cast(graph);
                try {
                    ManagementSystem mgmt;

                    // Declare all vertex labels.
                    for (String vLabel : vertexLabels) {
                        System.out.println(vLabel);
                        mgmt = (ManagementSystem) janusGraph.openManagement();
                        mgmt.makeVertexLabel(vLabel).make();
                        mgmt.commit();
                    }
                    logger.log(Level.INFO, "Vertex labels have been created");

                    // Declare all edge labels.
                    for (String eLabel : edgeLabels) {
                        System.out.println(eLabel);
                        mgmt = (ManagementSystem) janusGraph.openManagement();
                        mgmt.makeEdgeLabel(eLabel).multiplicity(Multiplicity.SIMPLE).make();
                        mgmt.commit();
                    }
                    logger.log(Level.INFO, "Edge labels have been created");

                    // Delcare all properties with Cardinality.SINGLE
                    for (String propKey : singleCardPropKeys) {
                        System.out.println(propKey);
                        mgmt = (ManagementSystem) janusGraph.openManagement();
                        mgmt.makePropertyKey(propKey).dataType(String.class)
                                .cardinality(Cardinality.SINGLE).make();
                        mgmt.commit();
                    }

                    // Delcare all properties with Cardinality.LIST
                    for (String propKey : listCardPropKeys) {
                        System.out.println(propKey);
                        mgmt = (ManagementSystem) janusGraph.openManagement();
                        mgmt.makePropertyKey(propKey).dataType(String.class)
                                .cardinality(Cardinality.LIST).make();
                        mgmt.commit();
                    }

                    /*
                     * Create a special ID property where we will store the IDs of
                     * vertices in the SNB dataset, and a corresponding index. This is
                     * necessary because TitanDB generates its own IDs for graph
                     * vertices, but the benchmark references vertices by the ID they
                     * were originally assigned during dataset generation.
                     */
                    mgmt = (ManagementSystem) janusGraph.openManagement();
                    mgmt.makePropertyKey("iid").dataType(String.class)
                            .cardinality(Cardinality.SINGLE).make();
                    mgmt.commit();
                    logger.log(Level.INFO, "ID property iid created");

                    mgmt = (ManagementSystem) janusGraph.openManagement();
                    PropertyKey iid = mgmt.getPropertyKey("iid");
                    mgmt.buildIndex("byIid", Vertex.class).addKey(iid).buildCompositeIndex();
                    mgmt.commit();
                    logger.log(Level.INFO, "Index on iid created");

                    mgmt.awaitGraphIndexStatus(janusGraph, "byIid").call();

                    mgmt = (ManagementSystem) janusGraph.openManagement();
                    mgmt.updateIndex(mgmt.getGraphIndex("byIid"), SchemaAction.REINDEX)
                            .get();
                    mgmt.commit();

                } catch (Exception e) {
                    logger.log(Level.SEVERE, e.toString());
                    return;
                }
            }
            long startTime = System.currentTimeMillis();
            for (String fileName : nodeFiles) {
                System.out.print("Loading node file " + fileName + " ");
                try {
                    loadVertices(graph, Paths.get(inputBaseDir + "/" + fileName),
                            true, batchSize, progReportPeriod);
                    System.out.println("Finished");
                } catch (NoSuchFileException e) {
                    System.out.println(" File not found.");
                }
            }

            for (String fileName : propertiesFiles) {
                System.out.print("Loading properties file " + fileName + " ");
                try {
                    loadProperties(graph, Paths.get(inputBaseDir + "/" + fileName),
                            true, batchSize, progReportPeriod);
                    System.out.println("Finished");
                } catch (NoSuchFileException e) {
                    System.out.println(" File not found.");
                }
            }

            for (String fileName : edgeFiles) {
                System.out.print("Loading edge file " + fileName + " ");
                try {
                    if (fileName.contains("person_knows_person")) {
                        loadEdges(graph, Paths.get(inputBaseDir + "/" + fileName), true,
                                true, batchSize, progReportPeriod);
                    } else {
                        loadEdges(graph, Paths.get(inputBaseDir + "/" + fileName), false,
                                true, batchSize, progReportPeriod);
                    }

                    System.out.println("Finished");
                } catch (NoSuchFileException e) {
                    System.out.println(" File not found.");
                }
            }
            long timeElapsed = System.currentTimeMillis() - startTime;
            System.out.println(String.format(
                    "Time Elapsed: %03dm.%02ds",
                    (timeElapsed / 1000) / 60, (timeElapsed / 1000) % 60));

            if (conf.getString("storage.backend").equals("inmemory")) {
                graph.io(IoCore.gryo()).writeGraph("sftiny_janus.gryo");
            }

            Iterator<Vertex> it = graph.traversal().V().hasLabel("Person");
            while (it.hasNext()) {
                Vertex a = it.next();
                System.out.println(a.property("iid"));
                Iterator<VertexProperty<String>> vpIt = a.properties("language");
                while (vpIt.hasNext()) {
                    VertexProperty<String> vp = vpIt.next();
                    System.out.print(vp.value() + " ");
                }
                System.out.println();
            }
//            String cypher = "MATCH (person:person) " +
//                    "RETURN person";
//            TranslationFacade cfog = new TranslationFacade();
//            String gremlin = cfog.toGremlinGroovy(cypher);
//            System.out.println(gremlin);
//            ScriptEngine engine = new GremlinGroovyScriptEngine();
//            Bindings bindings = engine.createBindings();
//            GraphTraversalSource g = graph.traversal();
//            bindings.put("g", g);
//            Object o = engine.eval(gremlin, bindings);
//            GraphTraversal<Vertex, Map<String, Object>> a = (GraphTraversal<Vertex, Map<String, Object>>) o;
//            while(a.hasNext()){
//                System.out.println(a.next());
//            }
            timeElapsed = System.currentTimeMillis() - startTime;
            System.out.println(String.format(
                    "Time Elapsed: %03dm.%02ds",
                    (timeElapsed / 1000) / 60, (timeElapsed / 1000) % 60));
        } catch (Exception e) {
            System.out.println("Exception: " + e);
            e.printStackTrace();
        }
    }
}