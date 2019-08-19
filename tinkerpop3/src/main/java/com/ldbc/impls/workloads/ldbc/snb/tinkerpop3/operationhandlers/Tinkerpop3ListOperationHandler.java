package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3DbConnectionState;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.ListOperationHandler;
import  org.apache.tinkerpop.gremlin.driver.ResultSet;
import  org.apache.tinkerpop.gremlin.driver.Result;
import  org.apache.tinkerpop.gremlin.driver.Client;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public abstract class Tinkerpop3ListOperationHandler<TOperation extends Operation<List<TOperationResult>>, TOperationResult>
        implements ListOperationHandler<TOperationResult, TOperation, Tinkerpop3DbConnectionState> {

    @Override
    public void executeOperation(TOperation operation, Tinkerpop3DbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
        Client client = state.getClient();
        List<TOperationResult> results = new ArrayList<>();
        int resultCount = 0;
        results.clear();

        final String queryString = getQueryString(state, operation);
        state.logQuery(operation.getClass().getSimpleName(), queryString);
        System.out.println("queryString = " + queryString);
        final ResultSet resultSet = client.submit(queryString);
        System.out.println("after submit.");
        Iterator<Result> iter = resultSet.iterator();
        System.out.println("hasNext = " + iter.hasNext());
        while (iter.hasNext()) {
            final Result result = iter.next();
            System.out.println(result);

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

    public abstract TOperationResult convertSingleResult(Result result) throws ParseException;
}

