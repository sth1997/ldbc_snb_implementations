WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "person#14",
    "p_personid" AS "person.id#14"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#14" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "current_from", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#4"
    FROM "knows" edgeTable),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#4", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "current_from"
    FROM "knows" edgeTable),
q4 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "friend#4" FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#4" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e208#0",
        "person#14" AS next_from,
        "person#14" AS "friend#4"
      FROM left_query
    )
    UNION ALL
    SELECT
      "person#14", "person.id#14",
      ("_e208#0"|| edge_id) AS "_e208#0",
      edges."friend#4" AS nextFrom,
      edges."friend#4"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e208#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e208#0") < 2
  )
  SELECT
    "person#14",
    "person.id#14",
    "_e208#0",
    "friend#4"
  FROM recursive_table
  WHERE array_length("_e208#0") >= 1),
q6 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "friend#4"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#14", left_query."person.id#14", left_query."_e208#0", left_query."friend#4" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#4" = right_query."friend#4"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT ROW(3, edgeTable."fp_forumid")::vertex_type AS "forum#4", ROW(4, edgeTable."fp_forumid", edgeTable."fp_personid")::edge_type AS "membership#0", ROW(0, edgeTable."fp_personid")::vertex_type AS "friend#4",
    fromTable."f_forumid" AS "forum.id#5", fromTable."f_title" AS "forum.title#2", edgeTable."fp_joindate" AS "membership.joinDate#0"
    FROM "forum_person" edgeTable
      JOIN "forum" fromTable ON (fromTable."f_forumid" = edgeTable."fp_forumid")),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."person#14", left_query."person.id#14", left_query."_e208#0", left_query."friend#4", right_query."forum.title#2", right_query."forum#4", right_query."membership#0", right_query."membership.joinDate#0", right_query."forum.id#5" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."friend#4" = right_query."friend#4"),
q10 AS
 (-- AllDifferent
  SELECT * FROM q9 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e208#0" || "membership#0")),
q11 AS
 (-- Selection
  SELECT * FROM q10 AS subquery
  WHERE (("membership.joinDate#0" > :minDate) AND NOT(("person#14" = "friend#4")))),
q12 AS
 (-- Projection
  SELECT "friend#4" AS "friend#4", "forum#4" AS "forum#4", "forum.id#5" AS "forum.id#5", "forum.title#2" AS "forum.title#2"
    FROM q11 AS subquery),
q13 AS
 (-- DuplicateElimination
  SELECT DISTINCT * FROM q12 AS subquery),
q14 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "post#5", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e209#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#4"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q15 AS
 (-- GetEdgesWithGTop
  SELECT ROW(3, toTable."m_ps_forumid")::vertex_type AS "forum#4", ROW(5, toTable."m_ps_forumid", toTable."m_messageid")::edge_type AS "_e210#0", ROW(6, toTable."m_messageid")::vertex_type AS "post#5"
    FROM "message" toTable
  WHERE (toTable."m_c_replyof" IS NULL)),
q16 AS
 (-- EquiJoinLike
  SELECT left_query."post#5", left_query."_e209#0", left_query."friend#4", right_query."forum#4", right_query."_e210#0" FROM
    q14 AS left_query
    INNER JOIN
    q15 AS right_query
  ON left_query."post#5" = right_query."post#5"),
q17 AS
 (-- AllDifferent
  SELECT * FROM q16 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e209#0" || "_e210#0")),
q18 AS
 (-- EquiJoinLike
  SELECT left_query."friend#4", left_query."forum#4", left_query."forum.id#5", left_query."forum.title#2", right_query."_e210#0", right_query."_e209#0", right_query."post#5" FROM
    q13 AS left_query
    LEFT OUTER JOIN
    q17 AS right_query
  ON left_query."friend#4" = right_query."friend#4" AND
     left_query."forum#4" = right_query."forum#4"),
q19 AS
 (-- Grouping
  SELECT "forum#4" AS "forum#4", count("post#5") AS "postCount#3", "forum.id#5" AS "forum.id#5", "forum.title#2" AS "forum.title#2"
    FROM q18 AS subquery
  GROUP BY "forum#4", "forum.id#5", "forum.title#2"),
q20 AS
 (-- Projection
  SELECT "forum.title#2" AS "forumTitle#0", "postCount#3" AS "postCount#3", "forum.id#5" AS "forum.id#5"
    FROM q19 AS subquery),
q21 AS
 (-- SortAndTop
  SELECT * FROM q20 AS subquery
    ORDER BY "postCount#3" DESC NULLS LAST, ("forum.id#5")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "forumTitle#0" AS "forumTitle", "postCount#3" AS "postCount"
  FROM q21 AS subquery