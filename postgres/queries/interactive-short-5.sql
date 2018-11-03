WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#2",
    "m_messageid" AS "m.id#2"
  FROM message
  WHERE (message."m_c_replyof" IS NULL)),
q1 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#2",
    "m_messageid" AS "m.id#2"
  FROM message
  WHERE (message."m_c_replyof" IS NOT NULL)),
q2 AS
 (-- UnionAll
  SELECT "m#2", "m.id#2" FROM q0
  UNION ALL
  SELECT "m#2", "m.id#2" FROM q1),
q3 AS
 (-- Selection
  SELECT * FROM q2 AS subquery
  WHERE ("m.id#2" = :messageId)),
q4 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "m#2", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e253#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "p#2",
    toTable."p_personid" AS "p.id#2", toTable."p_firstname" AS "p.firstName#0", toTable."p_lastname" AS "p.lastName#0"
    FROM "message" fromTable
      JOIN "person" toTable ON (fromTable."m_creatorid" = toTable."p_personid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
q5 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "m#2", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e253#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "p#2",
    toTable."p_personid" AS "p.id#2", toTable."p_firstname" AS "p.firstName#0", toTable."p_lastname" AS "p.lastName#0"
    FROM "message" fromTable
      JOIN "person" toTable ON (fromTable."m_creatorid" = toTable."p_personid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q6 AS
 (-- UnionAll
  SELECT "m#2", "_e253#0", "p#2", "p.id#2", "p.firstName#0", "p.lastName#0" FROM q4
  UNION ALL
  SELECT "m#2", "_e253#0", "p#2", "p.id#2", "p.firstName#0", "p.lastName#0" FROM q5),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."m#2", left_query."m.id#2", right_query."p.firstName#0", right_query."p.lastName#0", right_query."p#2", right_query."_e253#0", right_query."p.id#2" FROM
    q3 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."m#2" = right_query."m#2"),
-- q8 (AllDifferent): q7
q9 AS
 (-- Projection
  SELECT "p.id#2" AS "personId#7", "p.firstName#0" AS "firstName#2", "p.lastName#0" AS "lastName#2"
    FROM q7 AS subquery)
SELECT "personId#7" AS "personId", "firstName#2" AS "firstName", "lastName#2" AS "lastName"
  FROM q9 AS subquery