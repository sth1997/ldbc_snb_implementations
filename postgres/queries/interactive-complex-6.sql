WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "person#15",
    "p_personid" AS "person.id#15"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#15" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "current_from", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "friend#5"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#5", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "current_from"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#5" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e211#0",
        "person#15" AS next_from,
        "person#15" AS "friend#5"
      FROM left_query
    )
    UNION ALL
    SELECT
      "person#15", "person.id#15",
      ("_e211#0"|| edge_id) AS "_e211#0",
      edges."friend#5" AS nextFrom,
      edges."friend#5"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e211#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e211#0") < 2
  )
  SELECT
    "person#15",
    "person.id#15",
    "_e211#0",
    "friend#5"
  FROM recursive_table
  WHERE array_length("_e211#0") >= 1),
q6 AS
 (-- GetVertices
  SELECT
    p_personid AS "friend#5"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#15", left_query."person.id#15", left_query."_e211#0", left_query."friend#5" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#5" = right_query."friend#5"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "friendPost#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e212#0", "m_creatorid" AS "friend#5"
    FROM "message"),
q9 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "friendPost#0", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e213#0", "mt_tagid" AS "knownTag#0",
    "tag"."t_name" AS "knownTag.name#0"
    FROM "message_tag"
      JOIN "tag" ON ("message_tag"."mt_tagid" = "tag"."t_tagid")),
q10 AS
 (-- EquiJoinLike
  SELECT left_query."friendPost#0", left_query."_e212#0", left_query."friend#5", right_query."_e213#0", right_query."knownTag#0", right_query."knownTag.name#0" FROM
    q8 AS left_query
    INNER JOIN
    q9 AS right_query
  ON left_query."friendPost#0" = right_query."friendPost#0"),
q11 AS
 (-- Selection
  SELECT * FROM q10 AS subquery
  WHERE ("knownTag.name#0" = :tagName)),
q12 AS
 (-- EquiJoinLike
  SELECT left_query."person#15", left_query."person.id#15", left_query."_e211#0", left_query."friend#5", right_query."_e212#0", right_query."friendPost#0", right_query."knownTag#0", right_query."_e213#0", right_query."knownTag.name#0" FROM
    q7 AS left_query
    INNER JOIN
    q11 AS right_query
  ON left_query."friend#5" = right_query."friend#5"),
q13 AS
 (-- AllDifferent
  SELECT * FROM q12 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e211#0" || "_e212#0" || "_e213#0")),
q14 AS
 (-- Selection
  SELECT * FROM q13 AS subquery
  WHERE NOT(("person#15" = "friend#5"))),
q15 AS
 (-- GetEdgesWithGTop
  SELECT "ft_forumid" AS "friendPost#0", ROW("ft_forumid", "ft_tagid")::edge_type AS "_e214#0", "ft_tagid" AS "commonTag#0",
    "tag"."t_name" AS "commonTag.name#0"
    FROM "forum_tag"
      JOIN "tag" ON ("forum_tag"."ft_tagid" = "tag"."t_tagid")),
q16 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "friendPost#0", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e214#0", "mt_tagid" AS "commonTag#0",
    "tag"."t_name" AS "commonTag.name#0"
    FROM "message_tag"
      JOIN "tag" ON ("message_tag"."mt_tagid" = "tag"."t_tagid")),
q17 AS
 (-- UnionAll
  SELECT * FROM q15
  UNION ALL
  SELECT "friendPost#0", "_e214#0", "commonTag#0", "commonTag.name#0" FROM q16),
-- q18 (AllDifferent): q17
q19 AS
 (-- EquiJoinLike
  SELECT left_query."person#15", left_query."person.id#15", left_query."_e211#0", left_query."friend#5", left_query."friendPost#0", left_query."_e212#0", left_query."_e213#0", left_query."knownTag#0", left_query."knownTag.name#0", right_query."_e214#0", right_query."commonTag#0", right_query."commonTag.name#0" FROM
    q14 AS left_query
    INNER JOIN
    q17 AS right_query
  ON left_query."friendPost#0" = right_query."friendPost#0"),
q20 AS
 (-- Selection
  SELECT * FROM q19 AS subquery
  WHERE NOT(("commonTag#0" = "knownTag#0"))),
q21 AS
 (-- Projection
  SELECT "commonTag#0" AS "commonTag#0", "knownTag#0" AS "knownTag#0", "friend#5" AS "friend#5", "commonTag.name#0" AS "commonTag.name#0"
    FROM q20 AS subquery),
q22 AS
 (-- DuplicateElimination
  SELECT DISTINCT * FROM q21 AS subquery),
q23 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "commonPost#0", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e215#0", "mt_tagid" AS "commonTag#0"
    FROM "message_tag"),
q24 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "commonPost#0", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e216#0", "mt_tagid" AS "knownTag#0"
    FROM "message_tag"),
q25 AS
 (-- EquiJoinLike
  SELECT left_query."commonPost#0", left_query."_e215#0", left_query."commonTag#0", right_query."_e216#0", right_query."knownTag#0" FROM
    q23 AS left_query
    INNER JOIN
    q24 AS right_query
  ON left_query."commonPost#0" = right_query."commonPost#0"),
q26 AS
 (-- AllDifferent
  SELECT * FROM q25 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e215#0" || "_e216#0")),
q27 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "commonPost#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e217#0", "m_creatorid" AS "friend#5"
    FROM "message"),
q28 AS
 (-- EquiJoinLike
  SELECT left_query."commonPost#0", left_query."_e215#0", left_query."commonTag#0", left_query."_e216#0", left_query."knownTag#0", right_query."_e217#0", right_query."friend#5" FROM
    q26 AS left_query
    LEFT OUTER JOIN
    q27 AS right_query
  ON left_query."commonPost#0" = right_query."commonPost#0"),
q29 AS
 (-- EquiJoinLike
  SELECT left_query."commonTag#0", left_query."knownTag#0", left_query."friend#5", left_query."commonTag.name#0", right_query."_e216#0", right_query."_e217#0", right_query."commonPost#0", right_query."_e215#0" FROM
    q22 AS left_query
    INNER JOIN
    q28 AS right_query
  ON left_query."commonTag#0" = right_query."commonTag#0" AND
     left_query."knownTag#0" = right_query."knownTag#0" AND
     left_query."friend#5" = right_query."friend#5"),
q30 AS
 (-- Selection
  SELECT * FROM q29 AS subquery
  WHERE ((("friend#5" IS NOT NULL) AND ("_e217#0" IS NOT NULL)) AND ("commonPost#0" IS NOT NULL))),
q31 AS
 (-- Grouping
  SELECT "commonTag.name#0" AS "tagName#2", count("commonPost#0") AS "postCount#4"
    FROM q30 AS subquery
  GROUP BY "commonTag.name#0"),
q32 AS
 (-- SortAndTop
  SELECT * FROM q31 AS subquery
    ORDER BY "postCount#4" DESC NULLS LAST, "tagName#2" ASC NULLS FIRST
    LIMIT 10)
SELECT "tagName#2" AS "tagName", "postCount#4" AS "postCount"
  FROM q32 AS subquery