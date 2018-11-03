WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "person#15",
    "p_personid" AS "person.id#15"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#15" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "current_from", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#5"
    FROM "knows" edgeTable),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#5", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "current_from"
    FROM "knows" edgeTable),
q4 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "friend#5" FROM q2
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
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "friend#5"
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
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friendPost#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e212#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#5"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q9 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "friendPost#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e213#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "knownTag#0",
    toTable."t_name" AS "knownTag.name#0"
    FROM "message_tag" edgeTable
      JOIN "tag" toTable ON (edgeTable."mt_tagid" = toTable."t_tagid")
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
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
  SELECT ROW(3, edgeTable."ft_forumid")::vertex_type AS "friendPost#0", ROW(6, edgeTable."ft_forumid", edgeTable."ft_tagid")::edge_type AS "_e214#0", ROW(4, edgeTable."ft_tagid")::vertex_type AS "commonTag#0",
    toTable."t_name" AS "commonTag.name#0"
    FROM "forum_tag" edgeTable
      JOIN "tag" toTable ON (edgeTable."ft_tagid" = toTable."t_tagid")),
q16 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "friendPost#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e214#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "commonTag#0",
    toTable."t_name" AS "commonTag.name#0"
    FROM "message_tag" edgeTable
      JOIN "tag" toTable ON (edgeTable."mt_tagid" = toTable."t_tagid")
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
q17 AS
 (-- UnionAll
  SELECT "friendPost#0", "_e214#0", "commonTag#0", "commonTag.name#0" FROM q15
  UNION ALL
  SELECT "friendPost#0", "_e214#0", "commonTag#0", "commonTag.name#0" FROM q16),
q18 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "friendPost#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e214#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "commonTag#0",
    toTable."t_name" AS "commonTag.name#0"
    FROM "message_tag" edgeTable
      JOIN "tag" toTable ON (edgeTable."mt_tagid" = toTable."t_tagid")
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q19 AS
 (-- UnionAll
  SELECT "friendPost#0", "_e214#0", "commonTag#0", "commonTag.name#0" FROM q17
  UNION ALL
  SELECT "friendPost#0", "_e214#0", "commonTag#0", "commonTag.name#0" FROM q18),
-- q20 (AllDifferent): q19
q21 AS
 (-- EquiJoinLike
  SELECT left_query."person#15", left_query."person.id#15", left_query."_e211#0", left_query."friend#5", left_query."friendPost#0", left_query."_e212#0", left_query."_e213#0", left_query."knownTag#0", left_query."knownTag.name#0", right_query."_e214#0", right_query."commonTag#0", right_query."commonTag.name#0" FROM
    q14 AS left_query
    INNER JOIN
    q19 AS right_query
  ON left_query."friendPost#0" = right_query."friendPost#0"),
q22 AS
 (-- Selection
  SELECT * FROM q21 AS subquery
  WHERE NOT(("commonTag#0" = "knownTag#0"))),
q23 AS
 (-- Projection
  SELECT "commonTag#0" AS "commonTag#0", "knownTag#0" AS "knownTag#0", "friend#5" AS "friend#5", "commonTag.name#0" AS "commonTag.name#0"
    FROM q22 AS subquery),
q24 AS
 (-- DuplicateElimination
  SELECT DISTINCT * FROM q23 AS subquery),
q25 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "commonPost#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e215#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "commonTag#0"
    FROM "message_tag" edgeTable
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
q26 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "commonPost#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e216#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "knownTag#0"
    FROM "message_tag" edgeTable
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
q27 AS
 (-- EquiJoinLike
  SELECT left_query."commonPost#0", left_query."_e215#0", left_query."commonTag#0", right_query."_e216#0", right_query."knownTag#0" FROM
    q25 AS left_query
    INNER JOIN
    q26 AS right_query
  ON left_query."commonPost#0" = right_query."commonPost#0"),
q28 AS
 (-- AllDifferent
  SELECT * FROM q27 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e215#0" || "_e216#0")),
q29 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "commonPost#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e217#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#5"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q30 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "commonPost#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e217#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#5"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q31 AS
 (-- UnionAll
  SELECT "commonPost#0", "_e217#0", "friend#5" FROM q29
  UNION ALL
  SELECT "commonPost#0", "_e217#0", "friend#5" FROM q30),
q32 AS
 (-- EquiJoinLike
  SELECT left_query."commonPost#0", left_query."_e215#0", left_query."commonTag#0", left_query."_e216#0", left_query."knownTag#0", right_query."_e217#0", right_query."friend#5" FROM
    q28 AS left_query
    LEFT OUTER JOIN
    q31 AS right_query
  ON left_query."commonPost#0" = right_query."commonPost#0"),
q33 AS
 (-- EquiJoinLike
  SELECT left_query."commonTag#0", left_query."knownTag#0", left_query."friend#5", left_query."commonTag.name#0", right_query."_e216#0", right_query."_e217#0", right_query."commonPost#0", right_query."_e215#0" FROM
    q24 AS left_query
    INNER JOIN
    q32 AS right_query
  ON left_query."commonTag#0" = right_query."commonTag#0" AND
     left_query."knownTag#0" = right_query."knownTag#0" AND
     left_query."friend#5" = right_query."friend#5"),
q34 AS
 (-- Selection
  SELECT * FROM q33 AS subquery
  WHERE ((("friend#5" IS NOT NULL) AND ("_e217#0" IS NOT NULL)) AND ("commonPost#0" IS NOT NULL))),
q35 AS
 (-- Grouping
  SELECT "commonTag.name#0" AS "tagName#2", count("commonPost#0") AS "postCount#4"
    FROM q34 AS subquery
  GROUP BY "commonTag.name#0"),
q36 AS
 (-- SortAndTop
  SELECT * FROM q35 AS subquery
    ORDER BY "postCount#4" DESC NULLS LAST, "tagName#2" ASC NULLS FIRST
    LIMIT 10)
SELECT "tagName#2" AS "tagName", "postCount#4" AS "postCount"
  FROM q36 AS subquery