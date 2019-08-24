package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.SingletonOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3DbConnectionState;
import org.apache.tinkerpop.gremlin.driver.Client;
import org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;

import java.text.ParseException;
import java.util.Iterator;

public abstract class Tinkerpop3SingletonOperationWithSubqueryHandler<TOperation extends Operation<TOperationResult>, TOperationResult>
        implements SingletonOperationHandler<TOperationResult, TOperation, Tinkerpop3DbConnectionState> {
    @Override
    public void executeOperation(TOperation operation, Tinkerpop3DbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
        Client client = state.getClient();
        TOperationResult tuple = null;
        int resultCount = 0;

        final String queryString = getQueryString(state, operation);
        state.logQuery(operation.getClass().getSimpleName(), queryString);
        final ResultSet resultSet = client.submit(queryString);
        Iterator<Result> iter = resultSet.iterator();
        if (iter.hasNext()) {
            final Result result = iter.next();

            resultCount++;
            final String subQueryString = getSubQueryString(state, operation, result);
            final ResultSet resultSet2 = client.submit(subQueryString);
            try {
                tuple = convertSingleResult(result, resultSet2);
            } catch (ParseException e) {
                throw new DbException(e);
            }
            if (state.isPrintResults()) {
                System.out.println(tuple.toString());
            }
        }
        resultReporter.report(resultCount, tuple, operation);
    }

    public abstract String getSubQueryString(Tinkerpop3DbConnectionState state, TOperation operation, Result result);
    public abstract TOperationResult convertSingleResult(Result result, ResultSet subResultSet) throws ParseException;
}
