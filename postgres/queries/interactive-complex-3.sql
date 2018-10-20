WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "person#12",
    "p_personid" AS "person.id#12"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#12" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "current_from", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "friend#3"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#3", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "current_from"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#3" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e189#0",
        "person#12" AS next_from,
        "person#12" AS "friend#3"
      FROM left_query
    )
    UNION ALL
    SELECT
      "person#12", "person.id#12",
      ("_e189#0"|| edge_id) AS "_e189#0",
      edges."friend#3" AS nextFrom,
      edges."friend#3"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e189#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e189#0") < 2
  )
  SELECT
    "person#12",
    "person.id#12",
    "_e189#0",
    "friend#3"
  FROM recursive_table
  WHERE array_length("_e189#0") >= 1),
q6 AS
 (-- GetVertices
  SELECT
    p_personid AS "friend#3",
    "p_personid" AS "friend.id#3",
    "p_firstname" AS "friend.firstName#2",
    "p_lastname" AS "friend.lastName#3"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", right_query."friend.id#3", right_query."friend.firstName#2", right_query."friend.lastName#3" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "messageX#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e190#0", "m_creatorid" AS "friend#3",
    "message"."m_creationdate" AS "messageX.creationDate#0"
    FROM "message"),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", right_query."messageX#0", right_query."_e190#0", right_query."messageX.creationDate#0" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q10 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "messageX#0", ROW("m_messageid", "m_locationid")::edge_type AS "_e191#0", "m_locationid" AS "countryX#0",
    "place"."pl_name" AS "countryX.name#0"
    FROM "message"
      JOIN "place" ON ("message"."m_locationid" = "place"."pl_placeid")),
q11 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "messageX#0", ROW("o_organisationid", "o_placeid")::edge_type AS "_e191#0", "o_placeid" AS "countryX#0",
    "place"."pl_name" AS "countryX.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q12 AS
 (-- UnionAll
  SELECT * FROM q10
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q11),
q13 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "messageX#0", ROW("p_personid", "p_placeid")::edge_type AS "_e191#0", "p_placeid" AS "countryX#0",
    "place"."pl_name" AS "countryX.name#0"
    FROM "person"
      JOIN "place" ON ("person"."p_placeid" = "place"."pl_placeid")),
q14 AS
 (-- UnionAll
  SELECT * FROM q12
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q13),
q15 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", left_query."messageX#0", left_query."_e190#0", left_query."messageX.creationDate#0", right_query."_e191#0", right_query."countryX#0", right_query."countryX.name#0" FROM
    q9 AS left_query
    INNER JOIN
    q14 AS right_query
  ON left_query."messageX#0" = right_query."messageX#0"),
q16 AS
 (-- AllDifferent
  SELECT * FROM q15 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e191#0" || "_e189#0" || "_e190#0")),
q17 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "friend#3", ROW("m_messageid", "m_locationid")::edge_type AS "_e193#0", "m_locationid" AS "_e192#0"
    FROM "message"),
q18 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "friend#3", ROW("o_organisationid", "o_placeid")::edge_type AS "_e193#0", "o_placeid" AS "_e192#0"
    FROM "organisation"),
q19 AS
 (-- UnionAll
  SELECT * FROM q17
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q18),
q20 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "friend#3", ROW("p_personid", "p_placeid")::edge_type AS "_e193#0", "p_placeid" AS "_e192#0"
    FROM "person"),
q21 AS
 (-- UnionAll
  SELECT * FROM q19
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q20),
q22 AS
 (-- GetEdgesWithGTop
  SELECT "pl_placeid" AS "_e192#0", ROW("pl_placeid", "pl_containerplaceid")::edge_type AS "_e194#0", "pl_containerplaceid" AS "countryX#0"
    FROM "place"),
q23 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."_e193#0", left_query."_e192#0", right_query."_e194#0", right_query."countryX#0" FROM
    q21 AS left_query
    INNER JOIN
    q22 AS right_query
  ON left_query."_e192#0" = right_query."_e192#0"),
q24 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", left_query."messageX#0", left_query."_e190#0", left_query."messageX.creationDate#0", left_query."_e191#0", left_query."countryX#0", left_query."countryX.name#0", right_query."_e194#0", right_query."_e193#0", right_query."_e192#0" FROM
    q16 AS left_query
    LEFT OUTER JOIN
    q23 AS right_query
  ON left_query."friend#3" = right_query."friend#3" AND
     left_query."countryX#0" = right_query."countryX#0"),
q25 AS
 (-- Selection
  SELECT * FROM q24 AS subquery
  WHERE ((((NOT(("person#12" = "friend#3")) AND NOT(((((("countryX#0" IS NOT NULL) AND ("_e194#0" IS NOT NULL)) AND ("_e192#0" IS NOT NULL)) AND ("_e193#0" IS NOT NULL)) AND ("friend#3" IS NOT NULL)))) AND ("countryX.name#0" = :countryXName)) AND ("messageX.creationDate#0" >= :startDate)) AND ("messageX.creationDate#0" < :endDate))),
q26 AS
 (-- Grouping
  SELECT "friend#3" AS "friend#3", count(DISTINCT "messageX#0") AS "xCount#0", "friend.id#3" AS "friend.id#3", "friend.firstName#2" AS "friend.firstName#2", "friend.lastName#3" AS "friend.lastName#3"
    FROM q25 AS subquery
  GROUP BY "friend#3", "friend.id#3", "friend.firstName#2", "friend.lastName#3"),
q27 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "messageY#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e195#0", "m_creatorid" AS "friend#3",
    "message"."m_creationdate" AS "messageY.creationDate#0"
    FROM "message"),
q28 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "messageY#0", ROW("m_messageid", "m_locationid")::edge_type AS "_e196#0", "m_locationid" AS "countryY#0",
    "place"."pl_name" AS "countryY.name#0"
    FROM "message"
      JOIN "place" ON ("message"."m_locationid" = "place"."pl_placeid")),
q29 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "messageY#0", ROW("o_organisationid", "o_placeid")::edge_type AS "_e196#0", "o_placeid" AS "countryY#0",
    "place"."pl_name" AS "countryY.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q30 AS
 (-- UnionAll
  SELECT * FROM q28
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q29),
q31 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "messageY#0", ROW("p_personid", "p_placeid")::edge_type AS "_e196#0", "p_placeid" AS "countryY#0",
    "place"."pl_name" AS "countryY.name#0"
    FROM "person"
      JOIN "place" ON ("person"."p_placeid" = "place"."pl_placeid")),
q32 AS
 (-- UnionAll
  SELECT * FROM q30
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q31),
q33 AS
 (-- EquiJoinLike
  SELECT left_query."messageY#0", left_query."_e195#0", left_query."friend#3", left_query."messageY.creationDate#0", right_query."_e196#0", right_query."countryY#0", right_query."countryY.name#0" FROM
    q27 AS left_query
    INNER JOIN
    q32 AS right_query
  ON left_query."messageY#0" = right_query."messageY#0"),
q34 AS
 (-- AllDifferent
  SELECT * FROM q33 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e195#0" || "_e196#0")),
q35 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "friend#3", ROW("m_messageid", "m_locationid")::edge_type AS "_e198#0", "m_locationid" AS "_e197#0"
    FROM "message"),
q36 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "friend#3", ROW("o_organisationid", "o_placeid")::edge_type AS "_e198#0", "o_placeid" AS "_e197#0"
    FROM "organisation"),
q37 AS
 (-- UnionAll
  SELECT * FROM q35
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q36),
q38 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "friend#3", ROW("p_personid", "p_placeid")::edge_type AS "_e198#0", "p_placeid" AS "_e197#0"
    FROM "person"),
q39 AS
 (-- UnionAll
  SELECT * FROM q37
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q38),
q40 AS
 (-- GetEdgesWithGTop
  SELECT "pl_placeid" AS "_e197#0", ROW("pl_placeid", "pl_containerplaceid")::edge_type AS "_e199#0", "pl_containerplaceid" AS "countryY#0"
    FROM "place"),
q41 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."_e198#0", left_query."_e197#0", right_query."_e199#0", right_query."countryY#0" FROM
    q39 AS left_query
    INNER JOIN
    q40 AS right_query
  ON left_query."_e197#0" = right_query."_e197#0"),
q42 AS
 (-- EquiJoinLike
  SELECT left_query."messageY#0", left_query."_e195#0", left_query."friend#3", left_query."messageY.creationDate#0", left_query."_e196#0", left_query."countryY#0", left_query."countryY.name#0", right_query."_e199#0", right_query."_e198#0", right_query."_e197#0" FROM
    q34 AS left_query
    LEFT OUTER JOIN
    q41 AS right_query
  ON left_query."friend#3" = right_query."friend#3" AND
     left_query."countryY#0" = right_query."countryY#0"),
q43 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."xCount#0", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", right_query."_e198#0", right_query."countryY#0", right_query."countryY.name#0", right_query."messageY.creationDate#0", right_query."_e195#0", right_query."_e196#0", right_query."_e197#0", right_query."messageY#0", right_query."_e199#0" FROM
    q26 AS left_query
    INNER JOIN
    q42 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q44 AS
 (-- Selection
  SELECT * FROM q43 AS subquery
  WHERE (((("countryY.name#0" = :countryYName) AND NOT(((((("countryY#0" IS NOT NULL) AND ("_e199#0" IS NOT NULL)) AND ("_e197#0" IS NOT NULL)) AND ("_e198#0" IS NOT NULL)) AND ("friend#3" IS NOT NULL)))) AND ("messageY.creationDate#0" >= :startDate)) AND ("messageY.creationDate#0" < :endDate))),
q45 AS
 (-- Grouping
  SELECT "friend.id#3" AS "personId#1", "friend.firstName#2" AS "personFirstName#1", "friend.lastName#3" AS "personLastName#1", "xCount#0" AS "xCount#0", count(DISTINCT "messageY#0") AS "yCount#0"
    FROM q44 AS subquery
  GROUP BY "friend.id#3", "friend.firstName#2", "friend.lastName#3", "xCount#0"),
q46 AS
 (-- Projection
  SELECT "personId#1" AS "personId#1", "personFirstName#1" AS "personFirstName#1", "personLastName#1" AS "personLastName#1", "xCount#0" AS "xCount#0", "yCount#0" AS "yCount#0", ("xCount#0" + "yCount#0") AS "count#3"
    FROM q45 AS subquery),
q47 AS
 (-- SortAndTop
  SELECT * FROM q46 AS subquery
    ORDER BY "count#3" DESC NULLS LAST, ("personId#1")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#1" AS "personId", "personFirstName#1" AS "personFirstName", "personLastName#1" AS "personLastName", "xCount#0" AS "xCount", "yCount#0" AS "yCount", "count#3" AS "count"
  FROM q47 AS subquery