package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3;

import com.google.common.collect.ImmutableMap;
import com.ldbc.driver.DbException;
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


}