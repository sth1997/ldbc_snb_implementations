package com.ldbc.impls.workloads.ldbc.snb.tinkerpop.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.ListOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop.TinkerPopDbConnectionState;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.neo4j.driver.v1.Record;

import javax.script.ScriptException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static com.ldbc.impls.workloads.ldbc.snb.tinkerpop.operationhandlers.TinkerPopOperationHandlerUtils.*;

public abstract class TinkerPopListOperationHandler<TOperation extends Operation<List<TOperationResult>>, TOperationResult>
        implements ListOperationHandler<TOperationResult, TOperation, TinkerPopDbConnectionState> {

    @Override
    public void executeOperation(TOperation operation, TinkerPopDbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
        GraphTraversalSource traversalSource = state.getTraversal();
        List<TOperationResult> results = new ArrayList<>();
        int resultCount = 0;

        final String preProcessedCypherQuery = convertCypherQuery(getQueryString(state, operation));
        Iterator<Map<String, Object>> resultIterator;
        try {
            resultIterator = runQuery(traversalSource, preProcessedCypherQuery);
        } catch (ScriptException e) {
            throw new DbException(e);
        }
        while (resultIterator.hasNext()) {
            final Map<String, Object> result = resultIterator.next();

            resultCount++;
            TOperationResult tuple;
            try {
                tuple = convertSingleResult(result);
            } catch (ParseException e) {
                throw new DbException(e);
            }
            if (state.isPrintResults()) {
                System.out.println(tuple.toString());
            }
            results.add(tuple);
        }
        resultReporter.report(resultCount, results, operation);
    }

    public abstract TOperationResult convertSingleResult(Map<String, Object> result) throws ParseException;

}