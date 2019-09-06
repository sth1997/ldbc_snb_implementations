package com.ldbc.impls.workloads.ldbc.snb.tinkerpop3;

import com.google.common.primitives.Ints;
import com.ldbc.driver.DbException;
import com.ldbc.driver.control.LoggingService;
import com.ldbc.driver.workloads.ldbc.snb.interactive.*;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.converter.Tinkerpop3Converter;
import com.ldbc.impls.workloads.ldbc.snb.tinkerpop3.operationhandlers.*;
import com.ldbc.impls.workloads.ldbc.snb.db.BaseDb;
import org.apache.commons.lang.StringUtils;
import  org.apache.tinkerpop.gremlin.driver.Result;
import org.apache.tinkerpop.gremlin.driver.ResultSet;
import org.apache.tinkerpop.gremlin.structure.Edge;
import org.apache.tinkerpop.gremlin.structure.Vertex;
import org.apache.tinkerpop.gremlin.process.traversal.Path;

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
            Vertex person = (Vertex) ((Map) result.getObject()).get("a");
            return String.format("g.V('%s').union(out('isLocatedIn').values('name'),outE('studyAt').as('study').inV().as('u').out('isLocatedIn').as('city').select('study','u','city'),outE('workAt').as('we').inV().as('company').out('isLocatedIn').as('country').select('we','company','country'))", person.id().toString());
        }

        @Override
        public LdbcQuery1Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {

            Vertex person = (Vertex) ((Map) result.getObject()).get("a");
            List<String> emails;
            String[] emailStrs = ((String) person.property("email").value()).split(";");
            emails = Arrays.asList(emailStrs);
            List<String> languages;
            String[] languageStrs = ((String) person.property("language").value()).split(";");
            languages = Arrays.asList(languageStrs);
            List<List<Object>> universities;
            universities = new ArrayList<>();
            List<List<Object>> companies;
            companies = new ArrayList<>();

            String friendCityName = "";
            Iterator<Result> iter = subResultSet.iterator();
            while (iter.hasNext()) {
                Object obj = iter.next().getObject();
                if (obj instanceof String) {
                    friendCityName = (String) obj;
                } else {
                    Map otherInfo = (Map) obj;
                    if (otherInfo.containsKey("study")) //University
                    {
                        String universityName = (String) ((Vertex) otherInfo.get("u")).property("name").value();
                        Integer classYear = (Integer) ((Edge) otherInfo.get("study")).property("classYear").value();
                        String universityCity = (String) ((Vertex) otherInfo.get("city")).property("name").value();
                        universities.add(Arrays.asList(universityName, classYear, universityCity));
                    } else //Company
                    {
                        String companyName = (String) ((Vertex) otherInfo.get("company")).property("name").value();
                        Integer workFrom = (Integer) ((Edge) otherInfo.get("we")).property("workFrom").value();
                        String companyCountry = (String) ((Vertex) otherInfo.get("country")).property("name").value();
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

            //long friendId = Long.parseLong((String)person.property("id").value());
            long friendId = (long) person.property("id").value();
            String friendLastName = (String) person.property("lastName").value();
            int distanceFromPerson = ((Long) ((Map) result.getObject()).get("b")).intValue() - 1;
            long friendBirthday = Tinkerpop3Converter.convertLongDateToEpoch((long) person.property("birthday").value());
            long friendCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) person.property("creationDate").value());
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
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long messageId = (long) message.property("id").value();
            String messageContent = "";
            if (message.property("content").isPresent())
                messageContent = (String) message.property("content").value();
            else
                messageContent = (String) message.property("imageFile").value();
            long messageCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) message.property("creationDate").value());
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
            return String.format("g.V('%s').in('hasCreator').has('creationDate',inside(%s,%s)).filter(__.out('isLocatedIn').has('name',eq(%s))).count()", entry.getKey().id().toString(), startTime, endTime, countryY);
        }

        @Override
        public LdbcQuery3Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Map.Entry<Vertex, Long> entry = (Map.Entry) result.getObject();
            Vertex person = entry.getKey();
            long personId = (long) person.property("id").value();
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
            Map.Entry<Map, Long> entry = (Map.Entry) result.getObject();
            String tagName = (String) entry.getKey().get("name");
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
            Map.Entry<Map, Long> entry = (Map.Entry) result.getObject();
            String forumTitle = (String) entry.getKey().get("title");
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
            Map.Entry<String, Long> entry = (Map.Entry) result.getObject();
            String tagName = (String) entry.getKey();
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
            long friendId = (long) friend.property("id").value();
            return String.format("g.V().hasLabel('Person').has('id',%s).out('knows').has('Person', 'id', %d)", personId, friendId);
        }

        @Override
        public LdbcQuery7Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Vertex person = (Vertex) ((Map) result.getObject()).get("liker");
            Vertex message = (Vertex) ((Map) result.getObject()).get("message");
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long likeCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) ((Map) result.getObject()).get("likedate"));
            long messageId = (long) message.property("id").value();
            String messageContent = "";
            if (message.property("content").isPresent())
                messageContent = (String) message.property("content").value();
            else
                messageContent = (String) message.property("imageFile").value();
            int minutesLatency = Tinkerpop3Converter.convertStartAndEndDateToLatency((long) message.property("creationDate").value(), (long) ((Map) result.getObject()).get("likedate"));
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
            Vertex person = (Vertex) ((Map) result.getObject()).get("commenter");
            Vertex comment = (Vertex) ((Map) result.getObject()).get("comment");
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long commentCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) comment.property("creationDate").value());
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
            Vertex person = (Vertex) ((Map) result.getObject()).get("friends");
            Vertex message = (Vertex) ((Map) result.getObject()).get("post");
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            long messageId = (long) message.property("id").value();
            String messageContent = "";
            if (message.property("content").isPresent())
                messageContent = (String) message.property("content").value();
            else
                messageContent = (String) message.property("imageFile").value();
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
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            String organizationName = (String) map.get("orgname");
            int organizationWorkFromYear = ((Integer) map.get("works")).intValue();
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
            long personId =  (long) ((Map)((Map.Entry) result.getObject()).getKey()).get("id");
            String tagClassName = state.getQueryStore().getConverter().convertString(operation.tagClassName());
            return String.format("g.V().hasLabel('Person').has('id', %d).in('hasCreator').hasLabel('Comment').as('comment').out('replyOf').hasLabel('Post').out('hasTag').as('tag').out('hasType').has('name',within(%s)).select('tag').values('name').dedup()", personId, tagClassName);
        }

        @Override
        public LdbcQuery12Result convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Vertex person = (Vertex) ((Map.Entry) result.getObject()).getKey();
            long personId = (long) person.property("id").value();
            String personFirstName = (String) person.property("firstName").value();
            String personLastName = (String) person.property("lastName").value();
            List<String> tagNames = new ArrayList<>();
            Iterator<Result> iter = subResultSet.iterator();
            while (iter.hasNext()) {
                tagNames.add((String) iter.next().getObject());
            }
            int replyCount = ((Long) ((Map.Entry) result.getObject()).getValue()).intValue();
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

    public static class InteractiveQuery13 extends Tinkerpop3SingletonOperationHandler<LdbcQuery13, LdbcQuery13Result> {

        @Override
        public LdbcQuery13Result convertSingleResult(Result result) throws ParseException {
            return new LdbcQuery13Result(((Long) result.getObject()).intValue() - 1);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery13 operation) {
            if (operation.person1Id() == operation.person2Id())
                return new String("g.V().limit(1).count()");
            else
                return state.getQueryStore().getQuery13(operation);
        }
    }

    public static class InteractiveQuery14 extends Tinkerpop3ListOperationWithMultiSubqueryHandler<LdbcQuery14, LdbcQuery14Result> {

        @Override
        public List<String> getSubQueryStringList(Tinkerpop3DbConnectionState state, LdbcQuery14 operation, Result result) {
            Iterator iter = ((Path) result.getObject()).iterator();
            Vertex lastPerson = (Vertex) iter.next();
            List<String> subQueryList = new ArrayList<String>();
            subQueryList.clear();
            while (iter.hasNext()) {
                Vertex thisPerson = (Vertex) iter.next();
                subQueryList.add(String.format("g.timeout(600000).V('%s').in('hasCreator').out('replyOf').as('p').out('hasCreator').has('id', %d).select('p').label()", lastPerson.id().toString(), (long)thisPerson.property("id").value()));
                subQueryList.add(String.format("g.timeout(600000).V('%s').in('hasCreator').out('replyOf').as('p').out('hasCreator').has('id', %d).select('p').label()", thisPerson.id().toString(), (long)lastPerson.property("id").value()));
                lastPerson = thisPerson;
            }
            return subQueryList;
        }

        @Override
        public LdbcQuery14Result convertSingleResult(Result result, List<ResultSet> subResultSetList) throws ParseException {
            List<Long> personIdsInPath = new ArrayList<>();
            Iterator iter = ((Path) result.getObject()).iterator();
            while (iter.hasNext()) {
                personIdsInPath.add((Long)((Vertex) iter.next()).property("id").value());
            }
            double pathWeight = 0.0;
            for (ResultSet subResultSet : subResultSetList) {
                Iterator<Result> resultIter = subResultSet.iterator();
                while (resultIter.hasNext())
                    if (((String) resultIter.next().getObject()).equals("Post"))
                        pathWeight += 1.0;
                    else
                        pathWeight += 0.5;
            }
            return new LdbcQuery14Result(
                    personIdsInPath,
                    pathWeight);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcQuery14 operation) {
            return state.getQueryStore().getQuery14(operation);
        }
    }


    public static class ShortQuery1PersonProfile extends Tinkerpop3SingletonOperationHandler<LdbcShortQuery1PersonProfile, LdbcShortQuery1PersonProfileResult> {

        @Override
        public LdbcShortQuery1PersonProfileResult convertSingleResult(Result result) throws ParseException {
            Vertex person = (Vertex) ((Map) result.getObject()).get("p");
            String firstName = (String) person.property("firstName").value();
            String lastName = (String) person.property("lastName").value();
            long birthday = Tinkerpop3Converter.convertLongDateToEpoch((long) person.property("birthday").value());
            String locationIP = (String) person.property("locationIP").value();
            String browserUsed = (String) person.property("browserUsed").value();
            Vertex city = (Vertex) ((Map) result.getObject()).get("c");
            long cityId = (long) city.property("id").value();
            String gender = (String) person.property("gender").value();
            long creationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) person.property("creationDate").value());
            return new LdbcShortQuery1PersonProfileResult(
                    firstName,
                    lastName,
                    birthday,
                    locationIP,
                    browserUsed,
                    cityId,
                    gender,
                    creationDate);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery1PersonProfile operation) {
            return state.getQueryStore().getShortQuery1PersonProfile(operation);
        }
    }

    public static class ShortQuery2PersonPosts extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcShortQuery2PersonPosts, LdbcShortQuery2PersonPostsResult> {

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery2PersonPosts operation, Result result) {
            Vertex message = (Vertex) result.getObject();
            if (message.label().equals("Post"))
                return String.format("g.V('%s').out('hasCreator')", message.id().toString());
            else
                return String.format("g.V('%s').repeat(out('replyOf')).until(hasLabel('Post').or().loops().is(gt(6))).hasLabel('Post').as('post').out('hasCreator').as('person').select('post','person')", message.id().toString());
        }

        @Override
        public LdbcShortQuery2PersonPostsResult convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Vertex message = (Vertex) result.getObject();
            long messageId = (long) message.property("id").value();
            String messageContent = "";
            if (message.property("content").isPresent())
                messageContent = (String) message.property("content").value();
            else
                messageContent = (String) message.property("imageFile").value();
            long messageCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) message.property("creationDate").value());
            Result subResult = subResultSet.one();
            Vertex post;
            Vertex person;
            if (message.label().equals("Post")) {
                post = message;
                person = (Vertex) subResult.getObject();
            }
            else {
                post = (Vertex) ((Map) subResult.getObject()).get("post");
                person = (Vertex) ((Map) subResult.getObject()).get("person");
            }
            long originalPostId = (long) post.property("id").value();
            long originalPostAuthorId = (long) person.property("id").value();
            String originalPostAuthorFirstName = (String) person.property("firstName").value();
            String originalPostAuthorLastName = (String) person.property("lastName").value();
            return new LdbcShortQuery2PersonPostsResult(
                    messageId,
                    messageContent,
                    messageCreationDate,
                    originalPostId,
                    originalPostAuthorId,
                    originalPostAuthorFirstName,
                    originalPostAuthorLastName);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery2PersonPosts operation) {
            return state.getQueryStore().getShortQuery2PersonPosts(operation);
        }
    }

    public static class ShortQuery3PersonFriends extends Tinkerpop3ListOperationHandler<LdbcShortQuery3PersonFriends, LdbcShortQuery3PersonFriendsResult> {
        @Override
        public LdbcShortQuery3PersonFriendsResult convertSingleResult(Result result) throws ParseException {
            Vertex person = (Vertex) ((Map) result.getObject()).get("f");
            long personId = (long) person.property("id").value();
            String firstName = (String) person.property("firstName").value();
            String lastName = (String) person.property("lastName").value();
            long friendshipCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) ((Map) result.getObject()).get("kd"));
            return new LdbcShortQuery3PersonFriendsResult(
                    personId,
                    firstName,
                    lastName,
                    friendshipCreationDate);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery3PersonFriends operation) {
            return state.getQueryStore().getShortQuery3PersonFriends(operation);
        }
    }

    public static class ShortQuery4MessageContent extends Tinkerpop3SingletonOperationHandler<LdbcShortQuery4MessageContent, LdbcShortQuery4MessageContentResult> {

        @Override
        public LdbcShortQuery4MessageContentResult convertSingleResult(Result result) throws ParseException {
            Map map = (Map) result.getObject();
            long messageCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) map.get("creationDate"));
            String messageContent = "";
            if (map.containsKey("content"))
                messageContent = (String) map.get("content");
            else
                messageContent = (String) map.get("imageFile");
            return new LdbcShortQuery4MessageContentResult(
                    messageContent,
                    messageCreationDate);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery4MessageContent operation) {
            return state.getQueryStore().getShortQuery4MessageContent(operation);
        }
    }

    public static class ShortQuery5MessageCreator extends Tinkerpop3SingletonOperationHandler<LdbcShortQuery5MessageCreator, LdbcShortQuery5MessageCreatorResult> {

        @Override
        public LdbcShortQuery5MessageCreatorResult convertSingleResult(Result result) throws ParseException {
            Map map = (Map) result.getObject();
            long personId = (long) map.get("id");
            String firstName = (String) map.get("firstName");
            String lastName = (String) map.get("lastName");
            return new LdbcShortQuery5MessageCreatorResult(
                    personId,
                    firstName,
                    lastName);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery5MessageCreator operation) {
            return state.getQueryStore().getShortQuery5MessageCreator(operation);
        }
    }

    public static class ShortQuery6MessageForum extends Tinkerpop3SingletonOperationWithSubqueryHandler<LdbcShortQuery6MessageForum, LdbcShortQuery6MessageForumResult> {


        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery6MessageForum operation, Result result) {
            String label = (String) result.getObject();
            if (label.equals("Post"))
                return String.format("g.V().has('Post', 'id',%d).in('containerOf').as('f').out('hasModerator').as('p').select('f', 'p')", operation.messageId());
            else //Comment
                return String.format("g.V().has('Comment', 'id',%d).repeat(out('replyOf')).until(hasLabel('Post').or().loops().is(gt(10))).in('containerOf').as('f').out('hasModerator').as('p').select('f','p')", operation.messageId());
        }

        @Override
        public LdbcShortQuery6MessageForumResult convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Map map = (Map) subResultSet.one().getObject();
            Vertex forum = (Vertex) map.get("f");
            Vertex person = (Vertex) map.get("p");
            long forumId = (long) forum.property("id").value();
            String forumTitle = (String) forum.property("title").value();
            long moderatorId = (long) person.property("id").value();
            String moderatorFirstName = (String) person.property("firstName").value();
            String moderatorLastName = (String) person.property("lastName").value();
            return new LdbcShortQuery6MessageForumResult(
                    forumId,
                    forumTitle,
                    moderatorId,
                    moderatorFirstName,
                    moderatorLastName);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery6MessageForum operation) {
            return state.getQueryStore().getShortQuery6MessageForum(operation);
        }
    }

    public static class ShortQuery7MessageReplies extends Tinkerpop3ListOperationWithSubqueryHandler<LdbcShortQuery7MessageReplies, LdbcShortQuery7MessageRepliesResult> {

        @Override
        public String getSubQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery7MessageReplies operation, Result result) {
            Map map = (Map) result.getObject();
            Vertex person1 = (Vertex) map.get("p1");
            Vertex person2 = (Vertex) map.get("p2");
            return String.format("g.V('%s').out('knows').has('id', %d)", person1.id().toString(), (long) person2.property("id").value());
        }

        @Override
        public LdbcShortQuery7MessageRepliesResult convertSingleResult(Result result, ResultSet subResultSet) throws ParseException {
            Map map = (Map) result.getObject();
            Vertex person = (Vertex) map.get("p2");
            Vertex comment = (Vertex) map.get("r");
            long commentId = (long) comment.property("id").value();
            String commentContent = (String) comment.property("content").value();
            long commentCreationDate = Tinkerpop3Converter.convertLongTimestampToEpoch((long) comment.property("creationDate").value());
            long replyAuthorId = (long) person.property("id").value();
            String replyAuthorFirstName = (String) person.property("firstName").value();
            String replyAuthorLastName = (String) person.property("lastName").value();
            boolean replyAuthorKnowsOriginalMessageAuthor = (subResultSet.one() != null);
            return new LdbcShortQuery7MessageRepliesResult(
                    commentId,
                    commentContent,
                    commentCreationDate,
                    replyAuthorId,
                    replyAuthorFirstName,
                    replyAuthorLastName,
                    replyAuthorKnowsOriginalMessageAuthor);
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcShortQuery7MessageReplies operation) {
            return state.getQueryStore().getShortQuery7MessageReplies(operation);
        }
    }

    public static class Update1AddPerson extends Tinkerpop3UpdateOperationHandler<LdbcUpdate1AddPerson> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate1AddPerson operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Place').has('id', %d)", operation.cityId()));
            for (long tagId : operation.tagIds())
                ret.add(String.format("g.V().hasLabel('Tag').has('id', %d)", tagId));
            for (LdbcUpdate1AddPerson.Organization org : operation.studyAt())
                ret.add(String.format("g.V().hasLabel('Organisation').has('id', %d)", org.organizationId()));
            for (LdbcUpdate1AddPerson.Organization org : operation.workAt())
                ret.add(String.format("g.V().hasLabel('Organisation').has('id', %d)", org.organizationId()));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate1AddPerson operation, List<Vertex> vertices, Vertex person) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            Iterator<LdbcUpdate1AddPerson.Organization> universityIter = operation.studyAt().iterator();
            Iterator<LdbcUpdate1AddPerson.Organization> companyIter = operation.workAt().iterator();
            for (Vertex other : vertices) {
                switch (other.label()) {
                    case "Place":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'isLocatedIn')", person.id().toString(), other.id().toString()));
                        break;
                    case "Tag":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasInterest')", person.id().toString(), other.id().toString()));
                        break;
                    case "Organisation":
                        if (((String)other.property("type").value()).equals("University"))
                            ret.add(String.format("graph.addEdge('%s', '%s', label, 'studyAt', 'classYear', %d)", person.id().toString(), other.id().toString(), universityIter.next().year()));
                        else // Company
                            ret.add(String.format("graph.addEdge('%s', '%s', label, 'workAt', 'workFrom', %d", person.id().toString(), other.id().toString(), companyIter.next().year()));
                        break;
                }
            }
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate1AddPerson operation) {
            return state.getQueryStore().getUpdate1Single(operation);
        }
    }

    public static class Update2AddPostLike extends Tinkerpop3UpdateOperationHandler<LdbcUpdate2AddPostLike> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate2AddPostLike operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.personId()));
            ret.add(String.format("g.V().hasLabel('Post').has('id', %d)", operation.postId()));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate2AddPostLike operation, List<Vertex> vertices, Vertex newVertex) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            Vertex person = null, post = null;
            for (Vertex v : vertices)
                if (v.label().equals("Person"))
                    person = v;
                else
                    post = v;
            ret.add(String.format("graph.addEdge('%s', '%s', label, 'likes', 'creationDate', %s)", person.id().toString(), post.id().toString(), state.getQueryStore().getConverter().convertDateTime(operation.creationDate())));
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate2AddPostLike operation) {
            return null;
        }
    }

    public static class Update3AddCommentLike extends Tinkerpop3UpdateOperationHandler<LdbcUpdate3AddCommentLike> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate3AddCommentLike operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.personId()));
            ret.add(String.format("g.V().hasLabel('Comment').has('id', %d)", operation.commentId()));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate3AddCommentLike operation, List<Vertex> vertices, Vertex newVertex) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            Vertex person = null, comment = null;
            for (Vertex v : vertices)
                if (v.label().equals("Person"))
                    person = v;
                else
                    comment = v;
            ret.add(String.format("graph.addEdge('%s', '%s', label, 'likes', 'creationDate', %s)", person.id().toString(), comment.id().toString(), state.getQueryStore().getConverter().convertDateTime(operation.creationDate())));
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate3AddCommentLike operation) {
            return null;
        }
    }

    public static class Update4AddForum extends Tinkerpop3UpdateOperationHandler<LdbcUpdate4AddForum> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate4AddForum operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.moderatorPersonId()));
            for (long tagId : operation.tagIds())
                ret.add(String.format("g.V().hasLabel('Tag').has('id', %d)", tagId));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate4AddForum operation, List<Vertex> vertices, Vertex forum) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            for (Vertex other : vertices) {
                switch (other.label()) {
                    case "Person":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasModerator')", forum.id().toString(), other.id().toString()));
                        break;
                    case "Tag":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasTag')", forum.id().toString(), other.id().toString()));
                        break;
                }
            }
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate4AddForum operation) {
            return state.getQueryStore().getUpdate4Single(operation);
        }
    }

    public static class Update5AddForumMembership extends Tinkerpop3UpdateOperationHandler<LdbcUpdate5AddForumMembership> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate5AddForumMembership operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.personId()));
            ret.add(String.format("g.V().hasLabel('Forum').has('id', %d)", operation.forumId()));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate5AddForumMembership operation, List<Vertex> vertices, Vertex newVertex) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            Vertex forum =null, person = null;
            for (Vertex v : vertices)
                if (v.label().equals("Person"))
                    person = v;
                else
                    forum = v;
            ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasMember', 'joinDate', %s)", forum.id().toString(), person.id().toString(), state.getQueryStore().getConverter().convertDateTime(operation.joinDate())));
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate5AddForumMembership operation) {
            return null;
        }
    }

    public static class Update6AddPost extends Tinkerpop3UpdateOperationHandler<LdbcUpdate6AddPost> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate6AddPost operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Place').has('id', %d)", operation.countryId()));
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.authorPersonId()));
            ret.add(String.format("g.V().hasLabel('Forum').has('id', %d)", operation.forumId()));
            for (long tagId : operation.tagIds())
                ret.add(String.format("g.V().hasLabel('Tag').has('id', %d)", tagId));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate6AddPost operation, List<Vertex> vertices, Vertex post) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            for (Vertex other : vertices) {
                switch (other.label()) {
                    case "Place":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'isLocatedIn')", post.id().toString(), other.id().toString()));
                        break;
                    case "Person":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasCreator')", post.id().toString(), other.id().toString()));
                        break;
                    case "Forum":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'containerOf')", other.id().toString(), post.id().toString()));
                        break;
                    case "Tag":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasTag')", post.id().toString(), other.id().toString()));
                        break;
                }
            }
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate6AddPost operation) {
            String ret = state.getQueryStore().getUpdate6Single(operation);
            ret = StringUtils.substringBeforeLast(ret, ")");
            String contentStr = "", imageFileStr = "";
            if (!operation.content().equals(""))
                contentStr = ", 'content', " + state.getQueryStore().getConverter().convertString(operation.content());
            if (!operation.imageFile().equals(""))
                imageFileStr = ", 'imageFile', " + state.getQueryStore().getConverter().convertString(operation.imageFile());
            ret = ret + contentStr + imageFileStr + ")";
            return ret;
        }
    }

    public static class Update7AddComment extends Tinkerpop3UpdateOperationHandler<LdbcUpdate7AddComment> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate7AddComment operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Place').has('id', %d)", operation.countryId()));
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.authorPersonId()));
            if (operation.replyToCommentId() != -1)
                ret.add(String.format("g.V().hasLabel('Comment').has('id', %d)", operation.replyToCommentId()));
            if (operation.replyToPostId() != -1)
                ret.add(String.format("g.V().hasLabel('Post').has('id', %d)", operation.replyToPostId()));
            for (long tagId : operation.tagIds())
                ret.add(String.format("g.V().hasLabel('Tag').has('id', %d)", tagId));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate7AddComment operation, List<Vertex> vertices, Vertex comment) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            for (Vertex other : vertices) {
                switch (other.label()) {
                    case "Place":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'isLocatedIn')", comment.id().toString(), other.id().toString()));
                        break;
                    case "Person":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasCreator')", comment.id().toString(), other.id().toString()));
                        break;
                    case "Comment":
                    case "Post":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'replyOf')", comment.id().toString(), other.id().toString()));
                        break;
                    case "Tag":
                        ret.add(String.format("graph.addEdge('%s', '%s', label, 'hasTag')", comment.id().toString(), other.id().toString()));
                        break;
                }
            }
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate7AddComment operation) {
            return state.getQueryStore().getUpdate7Single(operation);
        }
    }

    public static class Update8AddFriendship extends Tinkerpop3UpdateOperationHandler<LdbcUpdate8AddFriendship> {

        @Override
        public List<String> getVerticesQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate8AddFriendship operation) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.person1Id()));
            ret.add(String.format("g.V().hasLabel('Person').has('id', %d)", operation.person2Id()));
            return ret;
        }

        @Override
        public List<String> getEdgesUpdateString(Tinkerpop3DbConnectionState state, LdbcUpdate8AddFriendship operation, List<Vertex> vertices, Vertex newVertex) {
            List<String> ret = new ArrayList<>();
            ret.clear();
            Vertex person1 = vertices.get(0);
            Vertex person2 = vertices.get(1);
            ret.add(String.format("graph.addEdge('%s', '%s', label, 'knows', 'creationDate', %s)", person1.id().toString(), person2.id().toString(), state.getQueryStore().getConverter().convertDateTime(operation.creationDate())));
            ret.add(String.format("graph.addEdge('%s', '%s', label, 'knows', 'creationDate', %s)", person2.id().toString(), person1.id().toString(), state.getQueryStore().getConverter().convertDateTime(operation.creationDate())));
            return ret;
        }

        @Override
        public String getQueryString(Tinkerpop3DbConnectionState state, LdbcUpdate8AddFriendship operation) {
            return null;
        }
    }
}
