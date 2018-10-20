WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "_e182#0",
    "p_personid" AS "_e182.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("_e182.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "current_from", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "friend#1"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#1", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "current_from"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#1" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "path#0",
        "_e182#0" AS next_from,
        "_e182#0" AS "friend#1"
      FROM left_query
    )
    UNION ALL
    SELECT
      "_e182#0", "_e182.id#0",
      ("path#0"|| edge_id) AS "path#0",
      edges."friend#1" AS nextFrom,
      edges."friend#1"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("path#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("path#0") < 3
  )
  SELECT
    "_e182#0",
    "_e182.id#0",
    "path#0",
    "friend#1"
  FROM recursive_table
  WHERE array_length("path#0") >= 1),
q6 AS
 (-- GetVertices
  SELECT
    p_personid AS "friend#1",
    "p_personid" AS "friend.id#1",
    "p_lastname" AS "friend.lastName#1",
    "p_birthday" AS "friend.birthday#0",
    "p_creationdate" AS "friend.creationDate#0",
    "p_gender" AS "friend.gender#0",
    "p_browserused" AS "friend.browserUsed#0",
    "p_locationip" AS "friend.locationIP#0",
    "p_lastname" AS "friend.lastName#0",
    "p_personid" AS "friend.id#0",
    "p_firstname" AS "friend.firstName#0"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."_e182#0", left_query."_e182.id#0", left_query."path#0", left_query."friend#1", right_query."friend.id#1", right_query."friend.lastName#0", right_query."friend.locationIP#0", right_query."friend.birthday#0", right_query."friend.firstName#0", right_query."friend.creationDate#0", right_query."friend.browserUsed#0", right_query."friend.gender#0", right_query."friend.id#0", right_query."friend.lastName#1" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q8 AS
 (-- AllDifferent
  SELECT * FROM q7 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "path#0")),
q9 AS
 (-- Selection
  SELECT * FROM q8 AS subquery
  WHERE ("friend.firstName#0" = :firstName)),
q10 AS
 (-- Grouping
  SELECT "friend#1" AS "friend#1", min(array_length("path#0")) AS "distance#0", "friend.id#1" AS "friend.id#1", "friend.lastName#1" AS "friend.lastName#1", "friend.birthday#0" AS "friend.birthday#0", "friend.creationDate#0" AS "friend.creationDate#0", "friend.gender#0" AS "friend.gender#0", "friend.browserUsed#0" AS "friend.browserUsed#0", "friend.locationIP#0" AS "friend.locationIP#0", "friend.lastName#0" AS "friend.lastName#0", "friend.id#0" AS "friend.id#0"
    FROM q9 AS subquery
  GROUP BY "friend#1", "friend.id#1", "friend.lastName#1", "friend.birthday#0", "friend.creationDate#0", "friend.gender#0", "friend.browserUsed#0", "friend.locationIP#0", "friend.lastName#0", "friend.id#0"),
q11 AS
 (-- SortAndTop
  SELECT * FROM q10 AS subquery
    ORDER BY "distance#0" ASC NULLS FIRST, "friend.lastName#0" ASC NULLS FIRST, ("friend.id#0")::BIGINT ASC NULLS FIRST
    LIMIT 20),
q12 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "friend#1", ROW("m_messageid", "m_locationid")::edge_type AS "_e183#0", "m_locationid" AS "friendCity#0",
    "place"."pl_name" AS "friendCity.name#0"
    FROM "message"
      JOIN "place" ON ("message"."m_locationid" = "place"."pl_placeid")),
q13 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "friend#1", ROW("o_organisationid", "o_placeid")::edge_type AS "_e183#0", "o_placeid" AS "friendCity#0",
    "place"."pl_name" AS "friendCity.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q14 AS
 (-- UnionAll
  SELECT * FROM q12
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q13),
q15 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "friend#1", ROW("p_personid", "p_placeid")::edge_type AS "_e183#0", "p_placeid" AS "friendCity#0",
    "place"."pl_name" AS "friendCity.name#0"
    FROM "person"
      JOIN "place" ON ("person"."p_placeid" = "place"."pl_placeid")),
q16 AS
 (-- UnionAll
  SELECT * FROM q14
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q15),
-- q17 (AllDifferent): q16
q18 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friend.lastName#0", left_query."friend.id#0", right_query."_e183#0", right_query."friendCity#0", right_query."friendCity.name#0" FROM
    q11 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q19 AS
 (-- GetEdgesWithGTop
  SELECT "pu_personid" AS "friend#1", ROW("pu_personid", "pu_organisationid")::edge_type AS "studyAt#0", "pu_organisationid" AS "uni#0",
    "organisation"."o_name" AS "uni.name#0", "person_university"."pu_classyear" AS "studyAt.classYear#0"
    FROM "person_university"
      JOIN "organisation" ON ("person_university"."pu_organisationid" = "organisation"."o_organisationid")),
q20 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "uni#0", ROW("o_organisationid", "o_placeid")::edge_type AS "_e184#0", "o_placeid" AS "uniCity#0",
    "place"."pl_name" AS "uniCity.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q21 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."studyAt#0", left_query."uni#0", left_query."uni.name#0", left_query."studyAt.classYear#0", right_query."_e184#0", right_query."uniCity#0", right_query."uniCity.name#0" FROM
    q19 AS left_query
    INNER JOIN
    q20 AS right_query
  ON left_query."uni#0" = right_query."uni#0"),
q22 AS
 (-- AllDifferent
  SELECT * FROM q21 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e184#0" || "studyAt#0")),
q23 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friend.lastName#0", left_query."friend.id#0", left_query."_e183#0", left_query."friendCity#0", left_query."friendCity.name#0", right_query."uniCity#0", right_query."uniCity.name#0", right_query."studyAt#0", right_query."uni.name#0", right_query."studyAt.classYear#0", right_query."_e184#0", right_query."uni#0" FROM
    q18 AS left_query
    LEFT OUTER JOIN
    q22 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q24 AS
 (-- Grouping
  SELECT "friend#1" AS "friend#1", array_agg(CASE WHEN ("uni.name#0" = NULL) THEN NULL
              ELSE ARRAY["uni.name#0", ("studyAt.classYear#0")::TEXT, "uniCity.name#0"]
         END) AS "unis#0", "friendCity#0" AS "friendCity#0", "distance#0" AS "distance#0", "friend.id#1" AS "friend.id#1", "friend.lastName#1" AS "friend.lastName#1", "friend.birthday#0" AS "friend.birthday#0", "friend.creationDate#0" AS "friend.creationDate#0", "friend.gender#0" AS "friend.gender#0", "friend.browserUsed#0" AS "friend.browserUsed#0", "friend.locationIP#0" AS "friend.locationIP#0", "friendCity.name#0" AS "friendCity.name#0"
    FROM q23 AS subquery
  GROUP BY "friend#1", "friendCity#0", "distance#0", "friend.id#1", "friend.lastName#1", "friend.birthday#0", "friend.creationDate#0", "friend.gender#0", "friend.browserUsed#0", "friend.locationIP#0", "friendCity.name#0"),
q25 AS
 (-- GetEdgesWithGTop
  SELECT "pc_personid" AS "friend#1", ROW("pc_personid", "pc_organisationid")::edge_type AS "workAt#0", "pc_organisationid" AS "company#0",
    "organisation"."o_name" AS "company.name#0", "person_company"."pc_workfrom" AS "workAt.workFrom#0"
    FROM "person_company"
      JOIN "organisation" ON ("person_company"."pc_organisationid" = "organisation"."o_organisationid")),
q26 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "company#0", ROW("o_organisationid", "o_placeid")::edge_type AS "_e185#0", "o_placeid" AS "companyCountry#0",
    "place"."pl_name" AS "companyCountry.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q27 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."workAt#0", left_query."company#0", left_query."company.name#0", left_query."workAt.workFrom#0", right_query."_e185#0", right_query."companyCountry#0", right_query."companyCountry.name#0" FROM
    q25 AS left_query
    INNER JOIN
    q26 AS right_query
  ON left_query."company#0" = right_query."company#0"),
q28 AS
 (-- AllDifferent
  SELECT * FROM q27 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e185#0" || "workAt#0")),
q29 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."unis#0", left_query."friendCity#0", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friendCity.name#0", right_query."workAt.workFrom#0", right_query."companyCountry.name#0", right_query."company#0", right_query."_e185#0", right_query."companyCountry#0", right_query."company.name#0", right_query."workAt#0" FROM
    q24 AS left_query
    LEFT OUTER JOIN
    q28 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q30 AS
 (-- Grouping
  SELECT "friend#1" AS "friend#1", array_agg(CASE WHEN ("company.name#0" = NULL) THEN NULL
              ELSE ARRAY["company.name#0", ("workAt.workFrom#0")::TEXT, "companyCountry.name#0"]
         END) AS "companies#0", "unis#0" AS "unis#0", "friendCity#0" AS "friendCity#0", "distance#0" AS "distance#0", "friend.id#1" AS "friend.id#1", "friend.lastName#1" AS "friend.lastName#1", "friend.birthday#0" AS "friend.birthday#0", "friend.creationDate#0" AS "friend.creationDate#0", "friend.gender#0" AS "friend.gender#0", "friend.browserUsed#0" AS "friend.browserUsed#0", "friend.locationIP#0" AS "friend.locationIP#0", "friendCity.name#0" AS "friendCity.name#0"
    FROM q29 AS subquery
  GROUP BY "friend#1", "unis#0", "friendCity#0", "distance#0", "friend.id#1", "friend.lastName#1", "friend.birthday#0", "friend.creationDate#0", "friend.gender#0", "friend.browserUsed#0", "friend.locationIP#0", "friendCity.name#0"),
q31 AS
 (-- Projection
  SELECT "friend.id#1" AS "friendId#0", "friend.lastName#1" AS "friendLastName#0", "distance#0" AS "distanceFromPerson#0", "friend.birthday#0" AS "friendBirthday#0", "friend.creationDate#0" AS "friendCreationDate#0", "friend.gender#0" AS "friendGender#0", "friend.browserUsed#0" AS "friendBrowserUsed#0", "friend.locationIP#0" AS "friendLocationIp#0", "friendCity.name#0" AS "friendCityName#0", "unis#0" AS "friendUniversities#0", "companies#0" AS "friendCompanies#0"
    FROM q30 AS subquery),
q32 AS
 (-- SortAndTop
  SELECT * FROM q31 AS subquery
    ORDER BY "distanceFromPerson#0" ASC NULLS FIRST, "friendLastName#0" ASC NULLS FIRST, ("friendId#0")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "friendId#0" AS "friendId", "friendLastName#0" AS "friendLastName", "distanceFromPerson#0" AS "distanceFromPerson", "friendBirthday#0" AS "friendBirthday", "friendCreationDate#0" AS "friendCreationDate", "friendGender#0" AS "friendGender", "friendBrowserUsed#0" AS "friendBrowserUsed", "friendLocationIp#0" AS "friendLocationIp", "friendCityName#0" AS "friendCityName", "friendUniversities#0" AS "friendUniversities", "friendCompanies#0" AS "friendCompanies"
  FROM q32 AS subquery