package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.ListOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3DbConnectionState;
import org.apache.tinkerpop.gremlin.driver.Client;
import org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

public abstract  class Tinkerpop3ListOperationWithMultiSubqueryHandler <TOperation extends Operation<List<TOperationResult>>, TOperationResult>
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
        final ResultSet resultSet = client.submit(queryString);
        Iterator<Result> iter = resultSet.iterator();
        while (iter.hasNext()) {
            final Result result = iter.next();
            resultCount++;
            final List<String> subQueryStringList = getSubQueryStringList(state, operation, result);
            if (subQueryStringList == null)
            {
                resultCount--;
                continue;
            }
            List<ResultSet> resultSetList = new ArrayList<ResultSet>();
            resultSetList.clear();
            for (String subQueryString : subQueryStringList)
                resultSetList.add(client.submit(subQueryString));
            TOperationResult tuple;
            try {
                tuple = convertSingleResult(result, resultSetList);
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

    public abstract List<String> getSubQueryStringList(Tinkerpop3DbConnectionState state, TOperation operation, Result result);
    public abstract TOperationResult convertSingleResult(Result result, List<ResultSet> subResultSetList) throws ParseException;
}
