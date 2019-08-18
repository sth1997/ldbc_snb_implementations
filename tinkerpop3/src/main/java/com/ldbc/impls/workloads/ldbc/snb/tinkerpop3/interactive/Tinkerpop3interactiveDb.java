package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.interactive;

import com.ldbc.driver.DbException;
import com.ldbc.driver.control.LoggingService;
import com.ldbc.driver.workloads.ldbc.snb.interactive.*;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.Tinkerpop3Db;

import java.util.Map;

public class Tinkerpop3interactiveDb extends Tinkerpop3Db{
    @Override
    protected void onInit(Map<String, String> properties, LoggingService loggingService) throws DbException {
        super.onInit(properties, loggingService);
        registerOperationHandler(LdbcQuery1.class, InteractiveQuery1.class);
    }
}
