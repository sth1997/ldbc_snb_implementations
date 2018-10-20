package com.ldbc.impls.workloads.ldbc.snb.postgres;

import com.google.common.collect.ImmutableMap;
import com.ldbc.driver.DbException;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery3;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery4;
import com.ldbc.impls.workloads.ldbc.snb.QueryStore;
import com.ldbc.impls.workloads.ldbc.snb.converter.Converter;
import com.ldbc.impls.workloads.ldbc.snb.postgres.converter.PostgresConverter;

import java.util.Calendar;
import java.util.Date;

public class PostgresQueryStore extends QueryStore {

    protected Converter getConverter() {
        return new PostgresConverter();
    }

    @Override
    protected String getParameterPrefix() {
        return ":";
    }

    public PostgresQueryStore(String path) throws DbException {
        super(path, ".sql");
    }

    protected Date addDays(Date startDate, int days){
        Calendar cal = Calendar.getInstance();
        cal.setTime(startDate);
        cal.add(Calendar.DATE, days);
        return cal.getTime();

    }

    @Override
    public String getQuery3(LdbcQuery3 operation) {
        // We can't use the DB's datetime lib, because currently the dates are stored as longs, see CypherConverter
        Date endDate = addDays(operation.startDate(), operation.durationDays());
        return prepare(QueryType.InteractiveComplexQuery3, new ImmutableMap.Builder<String, String>()
                .put("personId", getConverter().convertId(operation.personId()))
                .put("countryXName", getConverter().convertString(operation.countryXName()))
                .put("countryYName", getConverter().convertString(operation.countryYName()))
                .put("startDate", getConverter().convertDateTime(operation.startDate()))
                .put("endDate", getConverter().convertDateTime(endDate))
                .build());
    }

    public String getQuery4(LdbcQuery4 operation) {
        // We can't use the DB's datetime lib, because currently the dates are stored as longs, see CypherConverter
        Date endDate = addDays(operation.startDate(), operation.durationDays());
        return prepare(QueryType.InteractiveComplexQuery4, new ImmutableMap.Builder<String, String>()
                .put("personId", getConverter().convertId(operation.personId()))
                .put("startDate", getConverter().convertDateTime(operation.startDate()))
                .put("endDate", getConverter().convertDateTime(endDate))
                .build());
    }

}
