package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcNoResult;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3DbConnectionState;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.UpdateOperationHandler;

import  org.apache.tinkerpop.gremlin.driver.Client;


public abstract class Tinkerpop3UpdateOperationHandler<TOperation extends Operation<LdbcNoResult>>
        implements UpdateOperationHandler<TOperation, Tinkerpop3DbConnectionState> {

    @Override
    public void executeOperation(TOperation operation, Tinkerpop3DbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
        Client client = state.getClient();
        final String queryString = getQueryString(state, operation);
        state.logQuery(operation.getClass().getSimpleName(), queryString);
        client.submit(queryString);
        resultReporter.report(0, LdbcNoResult.INSTANCE, operation);
    }
}
