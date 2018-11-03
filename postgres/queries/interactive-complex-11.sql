WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "person#17",
    "p_personid" AS "person.id#17"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#17" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "current_from", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#7"
    FROM "knows" edgeTable),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#7", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "current_from"
    FROM "knows" edgeTable),
q4 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "friend#7" FROM q2
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
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "friend#7",
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
  SELECT ROW(0, edgeTable."pc_personid")::vertex_type AS "friend#7", ROW(12, edgeTable."pc_personid", edgeTable."pc_organisationid")::edge_type AS "workAt#1", ROW(1, edgeTable."pc_organisationid")::vertex_type AS "company#1",
    toTable."o_name" AS "company.name#1", edgeTable."pc_workfrom" AS "workAt.workFrom#1"
    FROM "person_company" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pc_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'university')),
q13 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."pc_personid")::vertex_type AS "friend#7", ROW(12, edgeTable."pc_personid", edgeTable."pc_organisationid")::edge_type AS "workAt#1", ROW(1, edgeTable."pc_organisationid")::vertex_type AS "company#1",
    toTable."o_name" AS "company.name#1", edgeTable."pc_workfrom" AS "workAt.workFrom#1"
    FROM "person_company" edgeTable
      JOIN "organisation" toTable ON (edgeTable."pc_organisationid" = toTable."o_organisationid")
  WHERE (toTable."o_type" :: text ~ 'company')),
q14 AS
 (-- UnionAll
  SELECT "friend#7", "workAt#1", "company#1", "company.name#1", "workAt.workFrom#1" FROM q12
  UNION ALL
  SELECT "friend#7", "workAt#1", "company#1", "company.name#1", "workAt.workFrom#1" FROM q13),
q15 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q16 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q17 AS
 (-- UnionAll
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q15
  UNION ALL
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q16),
q18 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q19 AS
 (-- UnionAll
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q17
  UNION ALL
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q18),
q20 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q21 AS
 (-- UnionAll
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q19
  UNION ALL
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q20),
q22 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q23 AS
 (-- UnionAll
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q21
  UNION ALL
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q22),
q24 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "company#1", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e239#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e238#0",
    toTable."pl_name" AS "_e238.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q25 AS
 (-- UnionAll
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q23
  UNION ALL
  SELECT "company#1", "_e239#0", "_e238#0", "_e238.name#0" FROM q24),
q26 AS
 (-- EquiJoinLike
  SELECT left_query."friend#7", left_query."workAt#1", left_query."company#1", left_query."company.name#1", left_query."workAt.workFrom#1", right_query."_e239#0", right_query."_e238#0", right_query."_e238.name#0" FROM
    q14 AS left_query
    INNER JOIN
    q25 AS right_query
  ON left_query."company#1" = right_query."company#1"),
q27 AS
 (-- Selection
  SELECT * FROM q26 AS subquery
  WHERE ("_e238.name#0" = :countryName)),
q28 AS
 (-- AllDifferent
  SELECT * FROM q27 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e239#0" || "workAt#1")),
q29 AS
 (-- EquiJoinLike
  SELECT left_query."friend#7", left_query."friend.id#5", left_query."friend.firstName#4", left_query."friend.lastName#5", right_query."_e238.name#0", right_query."_e238#0", right_query."workAt#1", right_query."company.name#1", right_query."company#1", right_query."_e239#0", right_query."workAt.workFrom#1" FROM
    q11 AS left_query
    INNER JOIN
    q28 AS right_query
  ON left_query."friend#7" = right_query."friend#7"),
q30 AS
 (-- Selection
  SELECT * FROM q29 AS subquery
  WHERE ("workAt.workFrom#1" < :workFromYear)),
q31 AS
 (-- Projection
  SELECT "friend.id#5" AS "personId#4", "friend.firstName#4" AS "personFirstName#4", "friend.lastName#5" AS "personLastName#4", "company.name#1" AS "organizationName#0", "workAt.workFrom#1" AS "organizationWorkFromYear#0"
    FROM q30 AS subquery),
q32 AS
 (-- SortAndTop
  SELECT * FROM q31 AS subquery
    ORDER BY "organizationWorkFromYear#0" ASC NULLS FIRST, ("personId#4")::BIGINT ASC NULLS FIRST, "organizationName#0" DESC NULLS LAST
    LIMIT 10)
SELECT "personId#4" AS "personId", "personFirstName#4" AS "personFirstName", "personLastName#4" AS "personLastName", "organizationName#0" AS "organizationName", "organizationWorkFromYear#0" AS "organizationWorkFromYear"
  FROM q32 AS subquery