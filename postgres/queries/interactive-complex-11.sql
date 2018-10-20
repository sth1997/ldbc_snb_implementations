WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "person#17",
    "p_personid" AS "person.id#17"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#17" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "current_from", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "friend#7"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#7", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "current_from"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#7" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e237#0",
        "person#17" AS next_from,
        "person#17" AS "friend#7"
      FROM left_query
    )
    UNION ALL
    SELECT
      "person#17", "person.id#17",
      ("_e237#0"|| edge_id) AS "_e237#0",
      edges."friend#7" AS nextFrom,
      edges."friend#7"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e237#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e237#0") < 2
  )
  SELECT
    "person#17",
    "person.id#17",
    "_e237#0",
    "friend#7"
  FROM recursive_table
  WHERE array_length("_e237#0") >= 1),
q6 AS
 (-- GetVertices
  SELECT
    p_personid AS "friend#7",
    "p_personid" AS "friend.id#5",
    "p_firstname" AS "friend.firstName#4",
    "p_lastname" AS "friend.lastName#5"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#17", left_query."person.id#17", left_query."_e237#0", left_query."friend#7", right_query."friend.id#5", right_query."friend.firstName#4", right_query."friend.lastName#5" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#7" = right_query."friend#7"),
q8 AS
 (-- AllDifferent
  SELECT * FROM q7 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e237#0")),
q9 AS
 (-- Selection
  SELECT * FROM q8 AS subquery
  WHERE NOT(("person#17" = "friend#7"))),
q10 AS
 (-- Projection
  SELECT "friend#7" AS "friend#7", "friend.id#5" AS "friend.id#5", "friend.firstName#4" AS "friend.firstName#4", "friend.lastName#5" AS "friend.lastName#5"
    FROM q9 AS subquery),
q11 AS
 (-- DuplicateElimination
  SELECT DISTINCT * FROM q10 AS subquery),
q12 AS
 (-- GetEdgesWithGTop
  SELECT "pc_personid" AS "friend#7", ROW("pc_personid", "pc_organisationid")::edge_type AS "workAt#1", "pc_organisationid" AS "company#1",
    "organisation"."o_name" AS "company.name#1", "person_company"."pc_workfrom" AS "workAt.workFrom#1"
    FROM "person_company"
      JOIN "organisation" ON ("person_company"."pc_organisationid" = "organisation"."o_organisationid")),
q13 AS
 (-- GetEdgesWithGTop
  SELECT "o_organisationid" AS "company#1", ROW("o_organisationid", "o_placeid")::edge_type AS "_e239#0", "o_placeid" AS "_e238#0",
    "place"."pl_name" AS "_e238.name#0"
    FROM "organisation"
      JOIN "place" ON ("organisation"."o_placeid" = "place"."pl_placeid")),
q14 AS
 (-- EquiJoinLike
  SELECT left_query."friend#7", left_query."workAt#1", left_query."company#1", left_query."company.name#1", left_query."workAt.workFrom#1", right_query."_e239#0", right_query."_e238#0", right_query."_e238.name#0" FROM
    q12 AS left_query
    INNER JOIN
    q13 AS right_query
  ON left_query."company#1" = right_query."company#1"),
q15 AS
 (-- Selection
  SELECT * FROM q14 AS subquery
  WHERE ("_e238.name#0" = :countryName)),
q16 AS
 (-- AllDifferent
  SELECT * FROM q15 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e239#0" || "workAt#1")),
q17 AS
 (-- EquiJoinLike
  SELECT left_query."friend#7", left_query."friend.id#5", left_query."friend.firstName#4", left_query."friend.lastName#5", right_query."_e238.name#0", right_query."_e238#0", right_query."workAt#1", right_query."company.name#1", right_query."company#1", right_query."_e239#0", right_query."workAt.workFrom#1" FROM
    q11 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."friend#7" = right_query."friend#7"),
q18 AS
 (-- Selection
  SELECT * FROM q17 AS subquery
  WHERE ("workAt.workFrom#1" < :workFromYear)),
q19 AS
 (-- Projection
  SELECT "friend.id#5" AS "personId#4", "friend.firstName#4" AS "personFirstName#4", "friend.lastName#5" AS "personLastName#4", "company.name#1" AS "organizationName#0", "workAt.workFrom#1" AS "organizationWorkFromYear#0"
    FROM q18 AS subquery),
q20 AS
 (-- SortAndTop
  SELECT * FROM q19 AS subquery
    ORDER BY "organizationWorkFromYear#0" ASC NULLS FIRST, ("personId#4")::BIGINT ASC NULLS FIRST, "organizationName#0" DESC NULLS LAST
    LIMIT 10)
SELECT "personId#4" AS "personId", "personFirstName#4" AS "personFirstName", "personLastName#4" AS "personLastName", "organizationName#0" AS "organizationName", "organizationWorkFromYear#0" AS "organizationWorkFromYear"
  FROM q20 AS subquery