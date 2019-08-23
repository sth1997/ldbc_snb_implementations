package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3;

import com.google.common.primitives.Ints;
import com.ldbc.driver.DbException;
import com.ldbc.driver.control.LoggingService;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery10TagPerson;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery10TagPersonResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery11UnrelatedReplies;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery11UnrelatedRepliesResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery12TrendingPosts;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery12TrendingPostsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery13PopularMonthlyTags;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery13PopularMonthlyTagsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery14TopThreadInitiators;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery14TopThreadInitiatorsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery15SocialNormals;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery15SocialNormalsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery16ExpertsInSocialCircle;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery16ExpertsInSocialCircleResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery17FriendshipTriangles;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery17FriendshipTrianglesResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery18PersonPostCounts;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery18PersonPostCountsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery19StrangerInteraction;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery19StrangerInteractionResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery1PostingSummary;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery1PostingSummaryResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery20HighLevelTopics;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery20HighLevelTopicsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery21Zombies;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery21ZombiesResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery22InternationalDialog;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery22InternationalDialogResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery23HolidayDestinations;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery23HolidayDestinationsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery24MessagesByTopic;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery24MessagesByTopicResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery25WeightedPaths;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery25WeightedPathsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery2TopTags;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery2TopTagsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery3TagEvolution;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery3TagEvolutionResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery4PopularCountryTopics;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery4PopularCountryTopicsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery5TopCountryPosters;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery5TopCountryPostersResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery6ActivePosters;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery6ActivePostersResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery7AuthoritativeUsers;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery7AuthoritativeUsersResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery8RelatedTopics;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery8RelatedTopicsResult;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery9RelatedForums;
import com.ldbc.driver.workloads.ldbc.snb.bi.LdbcSnbBiQuery9RelatedForumsResult;
import com.ldbc.driver.workloads.ldbc.snb.interactive.*;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.converter.Tinkerpop3Converter;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers.Tinkerpop3ListOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers.Tinkerpop3ListOperationWithSubqueryHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers.Tinkerpop3SingletonOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers.Tinkerpop3UpdateOperationHandler;
import com.ldbc.impls.workloads.ldbc.snb.db.BaseDb;
import  org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;
import org.apache.tinkerpop.gremlin.structure.Edge;
import org.apache.tinkerpop.gremlin.structure.Vertex;

import java.sql.SQLException;
import java.text.ParseException;
import java.util.*;


public abstract class Tinkerpop3Db extends BaseDb<Tinkerpop3QueryStore> {

    @Override
    protected void onInit(Map<String, String> properties, LoggingService loggingService) throws DbException {
        dcs = new Tinkerpop3DbConnectionState(properties, new Tinkerpop3QueryStore(properties.get("queryDir")));
    }

    // Interactive complex reads

    public static class InteractiveQuery1 extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcQuery1, LdbcQuery1Result> {

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery1 operation) {
            return state.getQueryStore().getQuery1(operation);
        }

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcQuery1 operation, Result result) {
            return String.format("g.V('%s').union(out('isLocatedIn').values('name'),outE('studyAt').as('study').inV().as('u').out('isLocatedIn').as('city').select('study','u','city'),outE('workAt').as('we').inV().as('company').out('isLocatedIn').as('country').select('we','company','country'))", ((Map) result.getObject()).get("a").toString());
        }

        @Override
        public LdbcQuery1Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {

            Vertex person = (Vertex) ((Map) result.getObject()).get("a");
            List<String> emails;
            String[] emailStrs = ((String)person.property("email").value()).split(";");
            emails = Arrays.asList(emailStrs);
            //TODO : language
            List<String> languages;
            String[] languageStrs = ((String)person.property("language").value()).split(";");
            languages = Arrays.asList(languageStrs);
            List<List<Object>> universities;
            universities = new ArrayList<>();
            List<List<Object>> companies;
            companies = new ArrayList<>();

            String friendCityName = "";
            Iterator<Result> iter = subResultSet.iterator();
            while (iter.hasNext()) {
                Object obj = iter.next().getObject();
                if (obj instanceof String)
                {
                    friendCityName = (String) obj;
                }
                else
                {
                    Map otherInfo = (Map) obj;
                    if (otherInfo.containsKey("study")) //University
                    {
                        String universityName = (String)((Vertex)otherInfo.get("u")).property("name").value();
                        Integer classYear = (Integer)((Edge)otherInfo.get("study")).property("classYear").value();
                        String universityCity = (String)((Vertex)otherInfo.get("city")).property("name").value();
                        universities.add(Arrays.asList(universityName, classYear, universityCity));
                    }
                    else //Company
                    {
                        String companyName = (String)((Vertex)otherInfo.get("company")).property("name").value();
                        Integer workFrom = (Integer)((Edge)otherInfo.get("we")).property("workFrom").value();
                        String companyCountry = (String)((Vertex)otherInfo.get("country")).property("name").value();
                        companies.add(Arrays.asList(companyName, workFrom, companyCountry));
                    }
                }
                /*Map otherInfo = (Map) iter.next().getObject();
                friendCityName = (String) ((Vertex) otherInfo.get("city")).property("name").value();
                long universityId = (long)((Vertex)otherInfo.get("u")).property("id").value();
                if (universityId != lastUniversityId) {
                    String universityName = (String)((Vertex)otherInfo.get("u")).property("name").value();
                    Integer classYear = (Integer)((Edge)otherInfo.get("study")).property("classYear").value();
                    String universityCity = (String)((Vertex)otherInfo.get("ucity")).property("name").value();
                    lastUniversityId = universityId;
                    universities.add(Arrays.asList(universityName, classYear, universityCity));
                }
                long companyId = (long)((Vertex)otherInfo.get("company")).property("id").value();
                if (companyId != lastCompanyId)
                {
                    String companyName = (String)((Vertex)otherInfo.get("company")).property("name").value();
                    Integer workFrom = (Integer)((Edge)otherInfo.get("we")).property("workFrom").value();
                    String companyCountry = (String)((Vertex)otherInfo.get("ccity")).property("name").value();
                    lastCompanyId = companyId;
                    companies.add(Arrays.asList(companyName, workFrom, companyCountry));
                }*/
            }

            //TODO : check type
            //long friendId = Long.parseLong((String)person.property("id").value());
            long friendId = (Long) person.property("id").value();
            String friendLastName = (String) person.property("lastName").value();
            int distanceFromPerson = ((Long)((Map) result.getObject()).get("b")).intValue() - 1;
            long friendBirthday = Tinkerpop3Converter.convertLongDateToEpoch((Long) person.property("birthday").value());
            long friendCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((Long) person.property("creationDate").value());
            String friendGender = (String) person.property("gender").value();
            String friendBrowserUsed = (String) person.property("browserUsed").value();
            String friendLocationIp = (String) person.property("locationIP").value();
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

    public static class InteractiveQuery2 extends Tinkerpop3ListOperationHandler<LdbcQuery2, LdbcQuery2Result> {
        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery2 operation) {
            return state.getQueryStore().getQuery2(operation);
        }

        @Override
        public LdbcQuery2Result convertSingleResult(Result result) throws ParseException {
            Vertex person = (Vertex) ((Map) result.getObject()).get("p");
            Vertex message = (Vertex) ((Map) result.getObject()).get("m");
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long messageId = (Long) message.property("id").value();
            //TODO : messageContent
            String messageContent = "";
            long messageCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((Long) message.property("creationDate").value());
            return new LdbcQuery2Result(
                    personId,
                    personFirstName,
                    personLastName,
                    messageId,
                    messageContent,
                    messageCreationDate);
        }
    }

    public static class InteractiveQuery3 extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcQuery3, LdbcQuery3Result> {

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcQuery3 operation, Result result) {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            String startTime = state.getQueryStore().getConverter().convertDateTime(operation.startDate());
            Date endDate = state.getQueryStore().addDays(operation.startDate(), operation.durationDays());
            String endTime = state.getQueryStore().getConverter().convertDateTime(endDate);
            String countryY = state.getQueryStore().getConverter().convertString(operation.countryYName());
            return String.format("g.V('%s').in('hasCreator').has('creationDate',inside(%s,%s)).filter(__.out('isLocatedIn').has('name',eq('%s'))).count()", entry.getKey().toString(), startTime, endTime, countryY);
        }

        @Override
        public LdbcQuery3Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            Vertex person = entry.getKey();
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            int xCount = entry.getValue().intValue();
            int yCount = ((Long) subResultSet.one().getObject()).intValue();
            int count = xCount + yCount;
            return new LdbcQuery3Result(
                    personId,
                    personFirstName,
                    personLastName,
                    xCount,
                    yCount,
                    count);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery3 operation) {
            return state.getQueryStore().getQuery3(operation);
        }
    }

    public static class InteractiveQuery4 extends Tinkerpop3ListOperationHandler<LdbcQuery4, LdbcQuery4Result> {

        @Override
        public LdbcQuery4Result convertSingleResult(Result result) throws ParseException {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            String tagName = (String)entry.getKey().property("name").value();
            int postCount = entry.getValue().intValue();
            return new LdbcQuery4Result(tagName, postCount);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery4 operation) {
            return state.getQueryStore().getQuery4(operation);
        }
    }

    public static class InteractiveQuery5 extends Tinkerpop3ListOperationHandler<LdbcQuery5, LdbcQuery5Result> {


        @Override
        public LdbcQuery5Result convertSingleResult(Result result) throws ParseException {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            String forumTitle = (String)entry.getKey().property("title").value();
            int postCount = entry.getValue().intValue();
            return new LdbcQuery5Result(forumTitle, postCount);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery5 operation) {
            return state.getQueryStore().getQuery5(operation);
        }
    }

    public static class InteractiveQuery6 extends Tinkerpop3ListOperationHandler<LdbcQuery6, LdbcQuery6Result> {

        @Override
        public LdbcQuery6Result convertSingleResult(Result result) throws ParseException {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            String tagName = (String)entry.getKey().property("name").value();
            int postCount = entry.getValue().intValue();
            return new LdbcQuery6Result(tagName, postCount);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery6 operation) {
            return state.getQueryStore().getQuery6(operation);
        }
    }

    public static class InteractiveQuery7 extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcQuery7, LdbcQuery7Result> {

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcQuery7 operation, Result result) {
            String personId = state.getQueryStore().getConverter().convertId(operation.personId());
            Vertex friend = (Vertex) ((Map) result.getObject()).get("liker");
            String friendId = (String) friend.property("id").value();
            return String.format("g.V().hasLabel('Person').has('id',%s).out('knows').has('Person', 'id', %s)", personId, friendId);
        }

        @Override
        public LdbcQuery7Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Vertex person = (Vertex) ((Map)result.getObject()).get("liker");
            Vertex message = (Vertex) ((Map)result.getObject()).get("message");
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long likeCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((Long) ((Map)result.getObject()).get("likedate"));
            long messageId = (Long) message.property("id").value();
            //TODO : messageContent
            String messageContent = "";
            int minutesLatency = Tinkerpop3Converter.convertStartAndEndDateToLatency((Long) message.property("creationDate").value(), likeCreationDate);
            boolean isNew = (subResultSet.one() == null);
            return new LdbcQuery7Result(
                    personId,
                    personFirstName,
                    personLastName,
                    likeCreationDate,
                    messageId,
                    messageContent,
                    minutesLatency,
                    isNew);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery7 operation) {
            return state.getQueryStore().getQuery7(operation);
        }
    }

    public static class InteractiveQuery8 extends Tinkerpop3ListOperationHandler<LdbcQuery8, LdbcQuery8Result> {

        @Override
        public LdbcQuery8Result convertSingleResult(Result result) throws ParseException {
            Vertex person = (Vertex) ((Map)result.getObject()).get("commenter");
            Vertex comment = (Vertex) ((Map)result.getObject()).get("comment");
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long commentCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((Long) comment.property("creationDate").value());
            long commentId = (long) comment.property("id").value();
            String commentContent = (String) comment.property("content").value();
            return new LdbcQuery8Result(
                    personId,
                    personFirstName,
                    personLastName,
                    commentCreationDate,
                    commentId,
                    commentContent);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery8 operation) {
            return state.getQueryStore().getQuery8(operation);
        }
    }

    public static class InteractiveQuery9 extends Tinkerpop3ListOperationHandler<LdbcQuery9, LdbcQuery9Result> {

        @Override
        public LdbcQuery9Result convertSingleResult(Result result) throws ParseException {
            Vertex person = (Vertex) ((Map)result.getObject()).get("liker");
            Vertex message = (Vertex) ((Map)result.getObject()).get("message");
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long messageId = (Long) message.property("id").value();
            String messageContent = (String) message.property("content").value();
            long messageCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) message.property("creationDate").value());
            return new LdbcQuery9Result(
                    personId,
                    personFirstName,
                    personLastName,
                    messageId,
                    messageContent,
                    messageCreationDate);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery9 operation) {
            return state.getQueryStore().getQuery9(operation);
        }
    }

    //TODO : InteractiveQuery10

    public static class InteractiveQuery11 extends Tinkerpop3ListOperationHandler<LdbcQuery11, LdbcQuery11Result> {

        @Override
        public LdbcQuery11Result convertSingleResult(Result result) throws ParseException {
            Map map = (Map) result.getObject();
            Vertex person = (Vertex) map.get("friends");
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            String organizationName = (String) map.get("orgname");
            //TODO : check type of "works"
            int organizationWorkFromYear = ((Long) map.get("works")).intValue();
            return new LdbcQuery11Result(
                    personId,
                    personFirstName,
                    personLastName,
                    organizationName,
                    organizationWorkFromYear);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery11 operation) {
            return state.getQueryStore().getQuery11(operation);
        }
    }

    public static class InteractiveQuery12 extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcQuery12, LdbcQuery12Result> {

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcQuery12 operation, Result result) {
            Vertex person = (Vertex) ((Map.Entry)result.getObject()).getKey();
            String tagClassName = state.getQueryStore().getConverter().convertString(operation.tagClassName());
            return String.format("g.V('%s').in('hasCreator').hasLabel('Comment').as('comment').out('replyOf').hasLabel('Post').out('hasTag').as('tag').out('hasType').has('name',within('%s')).select('tag').values('name').dedup()", person.toString(), tagClassName);
        }

        @Override
        public LdbcQuery12Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Vertex person = (Vertex) ((Map.Entry)result.getObject()).getKey();
            long personId = (Long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            //TODO : tagNames
            List<String> tagNames = new ArrayList<>();
            int replyCount = ((Long) ((Map.Entry)result.getObject()).getValue()).intValue();
            return new LdbcQuery12Result(
                    personId,
                    personFirstName,
                    personLastName,
                    tagNames,
                    replyCount);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery12 operation) {
            return state.getQueryStore().getQuery12(operation);
        }
    }

    //TODO : InteractiveQuery13

    //TODO : InteractiveQuery14
}
