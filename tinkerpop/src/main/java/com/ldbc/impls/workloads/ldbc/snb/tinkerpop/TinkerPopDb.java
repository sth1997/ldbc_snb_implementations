package com.ldbc.impls.workloads.ldbc.snb.tinkerpop;

import com.google.common.primitives.Ints;
import com.ldbc.driver.DbException;
import com.ldbc.driver.control.LoggingService;
import com.ldbc.driver.workloads.ldbc.snb.bi.*;
import com.ldbc.driver.workloads.ldbc.snb.interactive.*;
import com.ldbc.impls.workloads.ldbc.snb.cypher.CypherDbConnectionState;
import com.ldbc.impls.workloads.ldbc.snb.cypher.CypherQueryStore;
import com.ldbc.impls.workloads.ldbc.snb.cypher.converter.CypherConverter;
import com.ldbc.impls.workloads.ldbc.snb.cypher.operationhandlers.CypherListOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.cypher.operationhandlers.CypherSingletonOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.cypher.operationhandlers.CypherUpdateOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.db.BaseDb;
import org.neo4j.driver.v1.Record;
import org.neo4j.driver.v1.Values;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public abstract class TinkerPopDb extends BaseDb<TinkerPopQueryStore> {

    @Override
    protected void onInit(Map<String, String> properties, LoggingService loggingService) throws DbException {
        dcs = new TinkerPopDbConnectionState(properties, new TinkerPopQueryStore(properties.get("queryDir")));
    }

    // Interactive complex reads

    public static class InteractiveQuery1 extends CypherListOperationHandler<LdbcQuery1, LdbcQuery1Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery1 operation) {
            return state.getQueryStore().getQuery1(operation);
        }

        @Override
        public LdbcQuery1Result convertSingleResult(Record record) throws ParseException {

            List<String> emails;
            if (!record.get(8).isNull()) {
                emails = record.get(8).asList((e) -> e.asString());
            } else {
                emails = new ArrayList<>();
            }

            List<String> languages;
            if (!record.get(9).isNull()) {
                languages = record.get(9).asList((e) -> e.asString());
            } else {
                languages = new ArrayList<>();
            }

            List<List<Object>> universities;
            if (!record.get(11).isNull()) {
                universities = record.get(11).asList((e) ->
                        e.asList());
            } else {
                universities = new ArrayList<>();
            }

            List<List<Object>> companies;
            if (!record.get(12).isNull()) {
                companies = record.get(12).asList((e) ->
                        e.asList());
            } else {
                companies = new ArrayList<>();
            }

            long friendId = record.get(0).asLong();
            String friendLastName = record.get(1).asString();
            int distanceFromPerson = record.get(2).asInt();
            long friendBirthday = CypherConverter.convertLongDateToEpoch(record.get(3).asLong());
            long friendCreationDate = CypherConverter.convertLongTimestampToEpoch(record.get(4).asLong());
            String friendGender = record.get(5).asString();
            String friendBrowserUsed = record.get(6).asString();
            String friendLocationIp = record.get(7).asString();
            String friendCityName = record.get(10).asString();
            return new LdbcQuery1Result(
                    friendId,
                    friendLastName,
                    distanceFromPerson,
                    friendBirthday,
                    friendCreationDate,
                    friendGender,
                    friendBrowserUsed,
                    friendLocationIp,
                    emails,
                    languages,
                    friendCityName,
                    universities,
                    companies);
        }
    }

    public static class InteractiveQuery2 extends CypherListOperationHandler<LdbcQuery2, LdbcQuery2Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery2 operation) {
            return state.getQueryStore().getQuery2(operation);
        }

        @Override
        public LdbcQuery2Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            long postOrCommentId = record.get(3).asLong();
            String postOrCommentContent = record.get(4).asString();
            long postOrCommentCreationDate = CypherConverter.convertLongTimestampToEpoch(record.get(5).asLong());

            return new LdbcQuery2Result(
                    personId,
                    personFirstName,
                    personLastName,
                    postOrCommentId,
                    postOrCommentContent,
                    postOrCommentCreationDate);
        }
    }

    public static class InteractiveQuery3 extends CypherListOperationHandler<LdbcQuery3, LdbcQuery3Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery3 operation) {
            return state.getQueryStore().getQuery3(operation);
        }

        @Override
        public LdbcQuery3Result convertSingleResult(Record record) {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            int xCount = record.get(3).asInt();
            int yCount = record.get(4).asInt();
            int count = record.get(5).asInt();
            return new LdbcQuery3Result(
                    personId,
                    personFirstName,
                    personLastName,
                    xCount,
                    yCount,
                    count);
        }
    }

    public static class InteractiveQuery4 extends CypherListOperationHandler<LdbcQuery4, LdbcQuery4Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery4 operation) {
            return state.getQueryStore().getQuery4(operation);
        }

        @Override
        public LdbcQuery4Result convertSingleResult(Record record) {
            String tagName = record.get(0).asString();
            int postCount = record.get(1).asInt();
            return new LdbcQuery4Result(tagName, postCount);
        }

    }

    public static class InteractiveQuery5 extends CypherListOperationHandler<LdbcQuery5, LdbcQuery5Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery5 operation) {
            return state.getQueryStore().getQuery5(operation);
        }

        @Override
        public LdbcQuery5Result convertSingleResult(Record record) {
            String forumTitle = record.get(0).asString();
            int postCount = record.get(1).asInt();
            return new LdbcQuery5Result(forumTitle, postCount);
        }
    }

    public static class InteractiveQuery6 extends CypherListOperationHandler<LdbcQuery6, LdbcQuery6Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery6 operation) {
            return state.getQueryStore().getQuery6(operation);
        }

        @Override
        public LdbcQuery6Result convertSingleResult(Record record) {
            String tagName = record.get(0).asString();
            int postCount = record.get(1).asInt();
            return new LdbcQuery6Result(tagName, postCount);
        }
    }

    public static class InteractiveQuery7 extends CypherListOperationHandler<LdbcQuery7, LdbcQuery7Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery7 operation) {
            return state.getQueryStore().getQuery7(operation);
        }

        @Override
        public LdbcQuery7Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            long likeCreationDate = CypherConverter.convertLongTimestampToEpoch(record.get(3).asLong());
            long commentOrPostId = record.get(4).asLong();
            String commentOrPostContent = record.get(5).asString();
            int minutesLatency = CypherConverter.convertStartAndEndDateToLatency(record.get(6).asLong(), record.get(3).asLong());
            boolean isNew = record.get(7).asBoolean();
            return new LdbcQuery7Result(
                    personId,
                    personFirstName,
                    personLastName,
                    likeCreationDate,
                    commentOrPostId,
                    commentOrPostContent,
                    minutesLatency,
                    isNew);
        }
    }

    public static class InteractiveQuery8 extends CypherListOperationHandler<LdbcQuery8, LdbcQuery8Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery8 operation) {
            return state.getQueryStore().getQuery8(operation);
        }

        @Override
        public LdbcQuery8Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            long commentCreationDate = CypherConverter.convertLongTimestampToEpoch(record.get(3).asLong());
            long commentId = record.get(4).asLong();
            String commentContent = record.get(5).asString();
            return new LdbcQuery8Result(
                    personId,
                    personFirstName,
                    personLastName,
                    commentCreationDate,
                    commentId,
                    commentContent);
        }
    }

    public static class InteractiveQuery9 extends CypherListOperationHandler<LdbcQuery9, LdbcQuery9Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery9 operation) {
            return state.getQueryStore().getQuery9(operation);
        }

        @Override
        public LdbcQuery9Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            long commentOrPostId = record.get(3).asLong();
            String commentOrPostContent = record.get(4).asString();
            long commentOrPostCreationDate = CypherConverter.convertLongTimestampToEpoch(record.get(5).asLong());
            return new LdbcQuery9Result(
                    personId,
                    personFirstName,
                    personLastName,
                    commentOrPostId,
                    commentOrPostContent,
                    commentOrPostCreationDate);
        }
    }

    public static class InteractiveQuery10 extends CypherListOperationHandler<LdbcQuery10, LdbcQuery10Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery10 operation) {
            return state.getQueryStore().getQuery10(operation);
        }

        @Override
        public LdbcQuery10Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            int commonInterestScore = record.get(3).asInt();
            String personGender = record.get(4).asString();
            String personCityName = record.get(5).asString();
            return new LdbcQuery10Result(
                    personId,
                    personFirstName,
                    personLastName,
                    commonInterestScore,
                    personGender,
                    personCityName);
        }
    }

    public static class InteractiveQuery11 extends CypherListOperationHandler<LdbcQuery11, LdbcQuery11Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery11 operation) {
            return state.getQueryStore().getQuery11(operation);
        }

        @Override
        public LdbcQuery11Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            String organizationName = record.get(3).asString();
            int organizationWorkFromYear = record.get(4).asInt();
            return new LdbcQuery11Result(
                    personId,
                    personFirstName,
                    personLastName,
                    organizationName,
                    organizationWorkFromYear);
        }
    }

    public static class InteractiveQuery12 extends CypherListOperationHandler<LdbcQuery12, LdbcQuery12Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery12 operation) {
            return state.getQueryStore().getQuery12(operation);
        }

        @Override
        public LdbcQuery12Result convertSingleResult(Record record) throws ParseException {
            long personId = record.get(0).asLong();
            String personFirstName = record.get(1).asString();
            String personLastName = record.get(2).asString();
            List<String> tagNames = new ArrayList<>();
            if (!record.get(3).isNull()) {
                tagNames = record.get(3).asList((e) -> e.asString());
            }
            int replyCount = record.get(4).asInt();
            return new LdbcQuery12Result(
                    personId,
                    personFirstName,
                    personLastName,
                    tagNames,
                    replyCount);
        }
    }

    public static class InteractiveQuery13 extends CypherSingletonOperationHandler<LdbcQuery13, LdbcQuery13Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery13 operation) {
            return state.getQueryStore().getQuery13(operation);
        }

        @Override
        public LdbcQuery13Result convertSingleResult(Record record) {
            return new LdbcQuery13Result(record.get(0).asInt());
        }
    }

    public static class InteractiveQuery14 extends CypherListOperationHandler<LdbcQuery14, LdbcQuery14Result> {

        @Override
        public String getQueryString(CypherDbConnectionState state, LdbcQuery14 operation) {
            return state.getQueryStore().getQuery14(operation);
        }

        @Override
        public LdbcQuery14Result convertSingleResult(Record record) throws ParseException {
            List<Long> personIdsInPath = new ArrayList<>();
            if (!record.get(0).isNull()) {
                personIdsInPath = record.get(0).asList((e) -> e.asLong());
            }
            double pathWight = record.get(1).asDouble();
            return new LdbcQuery14Result(
                    personIdsInPath,
                    pathWight);
        }
    }
}
