WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#3",
    "m_messageid" AS "m.id#3"
  FROM message
  WHERE (message."m_c_replyof" IS NULL)),
q1 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#3",
    "m_messageid" AS "m.id#3"
  FROM message
  WHERE (message."m_c_replyof" IS NOT NULL)),
q2 AS
 (-- UnionAll
  SELECT "m#3", "m.id#3" FROM q0
  UNION ALL
  SELECT "m#3", "m.id#3" FROM q1),
q3 AS
 (-- Selection
  SELECT * FROM q2 AS subquery
  WHERE ("m.id#3" = :messageId)),
q4 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "current_from", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "edge_id", ROW(6, fromTable."m_c_replyof")::vertex_type AS "p#3"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."m_c_replyof" IS NULL)),
q5 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "current_from", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "edge_id", ROW(6, fromTable."m_c_replyof")::vertex_type AS "p#3"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."m_c_replyof" IS NOT NULL)),
q6 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "p#3" FROM q4
  UNION ALL
  SELECT "current_from", "edge_id", "p#3" FROM q5),
q7 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "current_from", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "edge_id", ROW(6, fromTable."m_c_replyof")::vertex_type AS "p#3"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NULL)),
q8 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "p#3" FROM q6
  UNION ALL
  SELECT "current_from", "edge_id", "p#3" FROM q7),
q9 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "current_from", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "edge_id", ROW(6, fromTable."m_c_replyof")::vertex_type AS "p#3"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NOT NULL)),
q10 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "p#3" FROM q8
  UNION ALL
  SELECT "current_from", "edge_id", "p#3" FROM q9),
q11 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q3)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e254#0",
        "m#3" AS next_from,
        "m#3" AS "p#3"
      FROM left_query
    )
    UNION ALL
    SELECT
      "m#3", "m.id#3",
      ("_e254#0"|| edge_id) AS "_e254#0",
      edges."p#3" AS nextFrom,
      edges."p#3"
    FROM (SELECT * FROM q10) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e254#0") -- edge uniqueness
           AND next_from = current_from
  )
  SELECT
    "m#3",
    "m.id#3",
    "_e254#0",
    "p#3"
  FROM recursive_table),
q12 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "p#3"
  FROM message
  WHERE (message."m_c_replyof" IS NULL)),
q13 AS
 (-- EquiJoinLike
  SELECT left_query."m#3", left_query."m.id#3", left_query."_e254#0", left_query."p#3" FROM
    q11 AS left_query
    INNER JOIN
    q12 AS right_query
  ON left_query."p#3" = right_query."p#3"),
q14 AS
 (-- GetEdgesWithGTop
  SELECT ROW(3, toTable."m_ps_forumid")::vertex_type AS "f#0", ROW(5, toTable."m_ps_forumid", toTable."m_messageid")::edge_type AS "_e255#0", ROW(6, toTable."m_messageid")::vertex_type AS "p#3",
    fromTable."f_forumid" AS "f.id#0", fromTable."f_title" AS "f.title#0"
    FROM "message" toTable
      JOIN "forum" fromTable ON (fromTable."f_forumid" = toTable."m_ps_forumid")
  WHERE (toTable."m_c_replyof" IS NULL)),
q15 AS
 (-- EquiJoinLike
  SELECT left_query."m#3", left_query."m.id#3", left_query."_e254#0", left_query."p#3", right_query."f.id#0", right_query."f.title#0", right_query."_e255#0", right_query."f#0" FROM
    q13 AS left_query
    INNER JOIN
    q14 AS right_query
  ON left_query."p#3" = right_query."p#3"),
q16 AS
 (-- GetEdgesWithGTop
  SELECT ROW(3, fromTable."f_forumid")::vertex_type AS "f#0", ROW(3, fromTable."f_forumid", fromTable."f_moderatorid")::edge_type AS "_e256#0", ROW(0, fromTable."f_moderatorid")::vertex_type AS "mod#0",
    toTable."p_personid" AS "mod.id#0", toTable."p_firstname" AS "mod.firstName#0", toTable."p_lastname" AS "mod.lastName#0"
    FROM "forum" fromTable
      JOIN "person" toTable ON (fromTable."f_moderatorid" = toTable."p_personid")),
q17 AS
 (-- EquiJoinLike
  SELECT left_query."m#3", left_query."m.id#3", left_query."_e254#0", left_query."p#3", left_query."f#0", left_query."_e255#0", left_query."f.id#0", left_query."f.title#0", right_query."mod.id#0", right_query."_e256#0", right_query."mod#0", right_query."mod.lastName#0", right_query."mod.firstName#0" FROM
    q15 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."f#0" = right_query."f#0"),
q18 AS
 (-- AllDifferent
  SELECT * FROM q17 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e256#0" || "_e254#0" || "_e255#0")),
q19 AS
 (-- Projection
  SELECT "f.id#0" AS "forumId#0", "f.title#0" AS "forumTitle#1", "mod.id#0" AS "moderatorId#0", "mod.firstName#0" AS "moderatorFirstName#0", "mod.lastName#0" AS "moderatorLastName#0"
    FROM q18 AS subquery)
SELECT "forumId#0" AS "forumId", "forumTitle#1" AS "forumTitle", "moderatorId#0" AS "moderatorId", "moderatorFirstName#0" AS "moderatorFirstName", "moderatorLastName#0" AS "moderatorLastName"
  FROM q19 AS subquery