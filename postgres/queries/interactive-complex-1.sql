WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "_e182#0",
    "p_personid" AS "_e182.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("_e182.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "current_from", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#1"
    FROM "knows" edgeTable),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#1", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "current_from"
    FROM "knows" edgeTable),
q4 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "friend#1" FROM q2
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
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "friend#1",
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
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q13 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q14 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q12
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q13),
q15 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q16 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q14
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q15),
q17 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q18 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q16
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q17),
q19 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q20 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q18
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q19),
q21 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#1", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e183#0", ROW(2, fromTable."m_locationid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q22 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q20
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q21),
q23 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q24 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q22
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q23),
q25 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q26 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q24
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q25),
q27 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q28 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q26
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q27),
q29 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q30 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q28
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q29),
q31 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q32 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q30
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q31),
q33 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."o_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q34 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q32
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q33),
q35 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#1", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."p_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'city')),
q36 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q34
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q35),
q37 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#1", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."p_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'country')),
q38 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q36
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q37),
q39 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#1", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e183#0", ROW(2, fromTable."p_placeid")::vertex_type AS "friendCity#0",
    toTable."pl_name" AS "friendCity.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'continent')),
q40 AS
 (-- UnionAll
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q38
  UNION ALL
  SELECT "friend#1", "_e183#0", "friendCity#0", "friendCity.name#0" FROM q39),
-- q41 (AllDifferent): q40
q42 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friend.lastName#0", left_query."friend.id#0", right_query."_e183#0", right_query."friendCity#0", right_query."friendCity.name#0" FROM
    q11 AS left_query
    INNER JOIN
    q40 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q43 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."pu_personid")::vertex_type AS "friend#1", ROW(13, edgeTable."pu_personid", edgeTable."pu_organisationid")::edge_type AS "studyAt#0", ROW(1, edgeTable."pu_organisationid")::vertex_type AS "uni#0",
    toTable."o_name" AS "uni.name#0", edgeTable."pu_classyear" AS "studyAt.classYear#0"
    FROM "person_university" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pu_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'university')),
q44 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."pu_personid")::vertex_type AS "friend#1", ROW(13, edgeTable."pu_personid", edgeTable."pu_organisationid")::edge_type AS "studyAt#0", ROW(1, edgeTable."pu_organisationid")::vertex_type AS "uni#0",
    toTable."o_name" AS "uni.name#0", edgeTable."pu_classyear" AS "studyAt.classYear#0"
    FROM "person_university" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pu_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'company')),
q45 AS
 (-- UnionAll
  SELECT "friend#1", "studyAt#0", "uni#0", "uni.name#0", "studyAt.classYear#0" FROM q43
  UNION ALL
  SELECT "friend#1", "studyAt#0", "uni#0", "uni.name#0", "studyAt.classYear#0" FROM q44),
q46 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q47 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q48 AS
 (-- UnionAll
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q46
  UNION ALL
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q47),
q49 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q50 AS
 (-- UnionAll
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q48
  UNION ALL
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q49),
q51 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q52 AS
 (-- UnionAll
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q50
  UNION ALL
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q51),
q53 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q54 AS
 (-- UnionAll
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q52
  UNION ALL
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q53),
q55 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "uni#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e184#0", ROW(2, fromTable."o_placeid")::vertex_type AS "uniCity#0",
    toTable."pl_name" AS "uniCity.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q56 AS
 (-- UnionAll
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q54
  UNION ALL
  SELECT "uni#0", "_e184#0", "uniCity#0", "uniCity.name#0" FROM q55),
q57 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."studyAt#0", left_query."uni#0", left_query."uni.name#0", left_query."studyAt.classYear#0", right_query."_e184#0", right_query."uniCity#0", right_query."uniCity.name#0" FROM
    q45 AS left_query
    INNER JOIN
    q56 AS right_query
  ON left_query."uni#0" = right_query."uni#0"),
q58 AS
 (-- AllDifferent
  SELECT * FROM q57 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e184#0" || "studyAt#0")),
q59 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friend.lastName#0", left_query."friend.id#0", left_query."_e183#0", left_query."friendCity#0", left_query."friendCity.name#0", right_query."uniCity#0", right_query."uniCity.name#0", right_query."studyAt#0", right_query."uni.name#0", right_query."studyAt.classYear#0", right_query."_e184#0", right_query."uni#0" FROM
    q42 AS left_query
    LEFT OUTER JOIN
    q58 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q60 AS
 (-- Grouping
  SELECT "friend#1" AS "friend#1", array_agg(CASE WHEN ("uni.name#0" = NULL) THEN NULL
              ELSE ARRAY["uni.name#0", ("studyAt.classYear#0")::TEXT, "uniCity.name#0"]
         END) AS "unis#0", "friendCity#0" AS "friendCity#0", "distance#0" AS "distance#0", "friend.id#1" AS "friend.id#1", "friend.lastName#1" AS "friend.lastName#1", "friend.birthday#0" AS "friend.birthday#0", "friend.creationDate#0" AS "friend.creationDate#0", "friend.gender#0" AS "friend.gender#0", "friend.browserUsed#0" AS "friend.browserUsed#0", "friend.locationIP#0" AS "friend.locationIP#0", "friendCity.name#0" AS "friendCity.name#0"
    FROM q59 AS subquery
  GROUP BY "friend#1", "friendCity#0", "distance#0", "friend.id#1", "friend.lastName#1", "friend.birthday#0", "friend.creationDate#0", "friend.gender#0", "friend.browserUsed#0", "friend.locationIP#0", "friendCity.name#0"),
q61 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."pc_personid")::vertex_type AS "friend#1", ROW(12, edgeTable."pc_personid", edgeTable."pc_organisationid")::edge_type AS "workAt#0", ROW(1, edgeTable."pc_organisationid")::vertex_type AS "company#0",
    toTable."o_name" AS "company.name#0", edgeTable."pc_workfrom" AS "workAt.workFrom#0"
    FROM "person_company" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pc_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'university')),
q62 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."pc_personid")::vertex_type AS "friend#1", ROW(12, edgeTable."pc_personid", edgeTable."pc_organisationid")::edge_type AS "workAt#0", ROW(1, edgeTable."pc_organisationid")::vertex_type AS "company#0",
    toTable."o_name" AS "company.name#0", edgeTable."pc_workfrom" AS "workAt.workFrom#0"
    FROM "person_company" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pc_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'company')),
q63 AS
 (-- UnionAll
  SELECT "friend#1", "workAt#0", "company#0", "company.name#0", "workAt.workFrom#0" FROM q61
  UNION ALL
  SELECT "friend#1", "workAt#0", "company#0", "company.name#0", "workAt.workFrom#0" FROM q62),
q64 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q65 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q66 AS
 (-- UnionAll
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q64
  UNION ALL
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q65),
q67 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q68 AS
 (-- UnionAll
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q66
  UNION ALL
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q67),
q69 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q70 AS
 (-- UnionAll
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q68
  UNION ALL
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q69),
q71 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q72 AS
 (-- UnionAll
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q70
  UNION ALL
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q71),
q73 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e185#0", ROW(2, fromTable."o_placeid")::vertex_type AS "companyCountry#0",
    toTable."pl_name" AS "companyCountry.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q74 AS
 (-- UnionAll
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q72
  UNION ALL
  SELECT "company#0", "_e185#0", "companyCountry#0", "companyCountry.name#0" FROM q73),
q75 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."workAt#0", left_query."company#0", left_query."company.name#0", left_query."workAt.workFrom#0", right_query."_e185#0", right_query."companyCountry#0", right_query."companyCountry.name#0" FROM
    q63 AS left_query
    INNER JOIN
    q74 AS right_query
  ON left_query."company#0" = right_query."company#0"),
q76 AS
 (-- AllDifferent
  SELECT * FROM q75 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e185#0" || "workAt#0")),
q77 AS
 (-- EquiJoinLike
  SELECT left_query."friend#1", left_query."unis#0", left_query."friendCity#0", left_query."distance#0", left_query."friend.id#1", left_query."friend.lastName#1", left_query."friend.birthday#0", left_query."friend.creationDate#0", left_query."friend.gender#0", left_query."friend.browserUsed#0", left_query."friend.locationIP#0", left_query."friendCity.name#0", right_query."workAt.workFrom#0", right_query."companyCountry.name#0", right_query."company#0", right_query."_e185#0", right_query."companyCountry#0", right_query."company.name#0", right_query."workAt#0" FROM
    q60 AS left_query
    LEFT OUTER JOIN
    q76 AS right_query
  ON left_query."friend#1" = right_query."friend#1"),
q78 AS
 (-- Grouping
  SELECT "friend#1" AS "friend#1", array_agg(CASE WHEN ("company.name#0" = NULL) THEN NULL
              ELSE ARRAY["company.name#0", ("workAt.workFrom#0")::TEXT, "companyCountry.name#0"]
         END) AS "companies#0", "unis#0" AS "unis#0", "friendCity#0" AS "friendCity#0", "distance#0" AS "distance#0", "friend.id#1" AS "friend.id#1", "friend.lastName#1" AS "friend.lastName#1", "friend.birthday#0" AS "friend.birthday#0", "friend.creationDate#0" AS "friend.creationDate#0", "friend.gender#0" AS "friend.gender#0", "friend.browserUsed#0" AS "friend.browserUsed#0", "friend.locationIP#0" AS "friend.locationIP#0", "friendCity.name#0" AS "friendCity.name#0"
    FROM q77 AS subquery
  GROUP BY "friend#1", "unis#0", "friendCity#0", "distance#0", "friend.id#1", "friend.lastName#1", "friend.birthday#0", "friend.creationDate#0", "friend.gender#0", "friend.browserUsed#0", "friend.locationIP#0", "friendCity.name#0"),
q79 AS
 (-- Projection
  SELECT "friend.id#1" AS "friendId#0", "friend.lastName#1" AS "friendLastName#0", "distance#0" AS "distanceFromPerson#0", "friend.birthday#0" AS "friendBirthday#0", "friend.creationDate#0" AS "friendCreationDate#0", "friend.gender#0" AS "friendGender#0", "friend.browserUsed#0" AS "friendBrowserUsed#0", "friend.locationIP#0" AS "friendLocationIp#0", "friendCity.name#0" AS "friendCityName#0", "unis#0" AS "friendUniversities#0", "companies#0" AS "friendCompanies#0"
    FROM q78 AS subquery),
q80 AS
 (-- SortAndTop
  SELECT * FROM q79 AS subquery
    ORDER BY "distanceFromPerson#0" ASC NULLS FIRST, "friendLastName#0" ASC NULLS FIRST, ("friendId#0")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "friendId#0" AS "friendId", "friendLastName#0" AS "friendLastName", "distanceFromPerson#0" AS "distanceFromPerson", "friendBirthday#0" AS "friendBirthday", "friendCreationDate#0" AS "friendCreationDate", "friendGender#0" AS "friendGender", "friendBrowserUsed#0" AS "friendBrowserUsed", "friendLocationIp#0" AS "friendLocationIp", "friendCityName#0" AS "friendCityName", "friendUniversities#0" AS "friendUniversities", "friendCompanies#0" AS "friendCompanies"
  FROM q80 AS subquery