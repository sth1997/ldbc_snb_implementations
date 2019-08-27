package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcNoResult;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3DbConnectionState;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.UpdateOperationHandler;

import  org.apache.tinkerpop.gremlin.driver.Client;
import org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;
import org.apache.tinkerpop.gremlin.structure.Vertex;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;


public abstract class Tinkerpop3UpdateOperationHandler<TOperation extends Operation<LdbcNoResult>>
        implements UpdateOperationHandler<TOperation, Tinkerpop3DbConnectionState> {

    @Override
    public void executeOperation(TOperation operation, Tinkerpop3DbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
        Client client = state.getClient();
        List<String> verticesQueryString = getVerticesQueryString(state, operation);
        List<Vertex> vertices = new ArrayList<>();
        vertices.clear();
        //Get vertices for adding edges.
        for (String query : verticesQueryString) {
            ResultSet resultSet = client.submit(query);
            //System.out.println("query vertex: " + query);
            vertices.add((Vertex) resultSet.one().getObject());
        }
        //Used to add a vertex.
        final String queryString = getQueryString(state, operation);
        Vertex newVertex = null;
        if (queryString != null) {
            state.logQuery(operation.getClass().getSimpleName(), queryString);
            ResultSet resultSet = client.submit(queryString);
            newVertex = (Vertex) resultSet.one().getObject();
        }
        else
            state.logQuery(operation.getClass().getSimpleName(), "");
        List<String> edgesUpdateString = getEdgesUpdateString(state, operation, vertices, newVertex);
        List<ResultSet> resultSetList = new ArrayList<>();
        resultSetList.clear();
        for (String update : edgesUpdateString) {
            //System.out.println(update);
            resultSetList.add(client.submit(update));
        }
        for (ResultSet resultSet : resultSetList) {
            Iterator<Result> iter = resultSet.iterator();
            Object obj;
            while (iter.hasNext())
                obj = iter.next().getObject();
        }
        resultReporter.report(0, LdbcNoResult.INSTANCE, operation);
    }

    public abstract List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, TOperation operation);
    public abstract List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, TOperation operation, List<Vertex> vertices, Vertex newVertex);
}
