package com.ldbc.impls.workloads.ldbc.snb.tinkerpop.operationhandlers;

import com.ldbc.driver.DbException;
import com.ldbc.driver.Operation;
import com.ldbc.driver.ResultReporter;
import com.ldbc.impls.workloads.ldbc.snb.operationhandlers.SingletonOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop.TinkerPopDbConnectionState;
import org.neo4j.driver.v1.Record;

import java.text.ParseException;

public abstract class TinkerPopSingletonOperationHandler<TOperation extends Operation<TOperationResult>, TOperationResult>
        implements SingletonOperationHandler<TOperationResult, TOperation, TinkerPopDbConnectionState> {

    @Override
    public void executeOperation(TOperation operation, TinkerPopDbConnectionState state,
                                 ResultReporter resultReporter) throws DbException {
//        try (Session session = state.getSession()) {
//            TOperationResult tuple = null;
//            int resultCount = 0;
//
//            final String queryString = getQueryString(state, operation);
//            state.logQuery(operation.getClass().getSimpleName(), queryString);
//            final StatementResult result = session.run(queryString);
//            if (result.hasNext()) {
//                final Record record = result.next();
//                resultCount++;
//
//                tuple = convertSingleResult(record);
//
//                if (state.isPrintResults()) {
//                    System.out.println(tuple.toString());
//                }
//            }
//            session.close();
//
//            resultReporter.report(resultCount, tuple, operation);
//        } catch (Exception e) {
//            throw new DbException(e);
//        }
    }

    public abstract TOperationResult convertSingleResult(Record record) throws ParseException;

}
