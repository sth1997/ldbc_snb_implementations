package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3;

import com.google.common.collect.ImmutableMap;
import com.ldbc.driver.DbException;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery3;
import com.ldbc.driver.workloads.ldbc.snb.interactive.LdbcQuery4;
import com.ldbc.impls.workloads.ldbc.snb.QueryStore;
import com.ldbc.impls.workloads.ldbc.snb.converter.Converter;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.converter.Tinkerpop3Converter;


import java.util.Calendar;
import java.util.Date;

public class Tinkerpop3QueryStore extends QueryStore {
    public Converter getConverter() {
        return new Tinkerpop3Converter();
    }

    public Tinkerpop3QueryStore(String path) throws DbException {
        super(path, ".gremlin");
    }

    protected Date addDays(Date startDate, int days){
        Calendar cal = Calendar.getInstance();
        cal.setTime(startDate);
        cal.add(Calendar.DATE, days);
        return cal.getTime();
    }

    @Override
    public String getQuery3(LdbcQuery3 operation) {
        // We can't use the DB's datetime lib, because currently the dates are stored as longs, see Tinkerpop3Converter
        Date endDate = addDays(operation.startDate(), operation.durationDays());
        return prepare(QueryType.InteractiveComplexQuery3, new ImmutableMap.Builder<String, String>()
                .put("personId", getConverter().convertId(operation.personId()))
                .put("countryXName", getConverter().convertString(operation.countryXName()))
                .put("countryYName", getConverter().convertString(operation.countryYName()))
                .put("startDate", getConverter().convertDateTime(operation.startDate()))
                .put("endDate", getConverter().convertDateTime(endDate))
                .build());
    }

    @Override
    public String getQuery4(LdbcQuery4 operation) {
        // We can't use the DB's datetime lib, because currently the dates are stored as longs, see Tinkerpop3Converter
        Date endDate = addDays(operation.startDate(), operation.durationDays());
        return prepare(QueryType.InteractiveComplexQuery4, new ImmutableMap.Builder<String, String>()
                .put("personId", getConverter().convertId(operation.personId()))
                .put("startDate", getConverter().convertDateTime(operation.startDate()))
                .put("endDate", getConverter().convertDateTime(endDate))
                .build());
    }


}