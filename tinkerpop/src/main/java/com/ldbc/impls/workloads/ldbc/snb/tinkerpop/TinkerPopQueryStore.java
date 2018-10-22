package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.ldbc.driver.DbException;
import com.ldbc.impls.workloads.ldbc.snb.cypher.CypherQueryStore;

public class TinkerPopQueryStore extends CypherQueryStore {

    public TinkerPopQueryStore(String path) throws DbException {
        super(path);
    }
}
