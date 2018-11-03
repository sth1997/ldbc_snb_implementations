WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "start#0",
    "p_personid" AS "start.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("start.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "_e219#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e220#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "start#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "_e219#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e220#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "start#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q4 AS
 (-- UnionAll
  SELECT "_e219#0", "_e220#0", "start#0" FROM q2
  UNION ALL
  SELECT "_e219#0", "_e220#0", "start#0" FROM q3),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", right_query."_e219#0", right_query."_e220#0" FROM
    q1 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."start#0" = right_query."start#0"),
q6 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "comment#3", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "_e221#0", ROW(6, fromTable."m_c_replyof")::vertex_type AS "_e219#0",
    fromTable."m_creationdate" AS "comment.creationDate#0", fromTable."m_messageid" AS "comment.id#0", fromTable."m_content" AS "comment.content#0"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NULL)),
q7 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "comment#3", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "_e221#0", ROW(6, fromTable."m_c_replyof")::vertex_type AS "_e219#0",
    fromTable."m_creationdate" AS "comment.creationDate#0", fromTable."m_messageid" AS "comment.id#0", fromTable."m_content" AS "comment.content#0"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NOT NULL)),
q8 AS
 (-- UnionAll
  SELECT "comment#3", "_e221#0", "_e219#0", "comment.creationDate#0", "comment.id#0", "comment.content#0" FROM q6
  UNION ALL
  SELECT "comment#3", "_e221#0", "_e219#0", "comment.creationDate#0", "comment.id#0", "comment.content#0" FROM q7),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", left_query."_e219#0", left_query."_e220#0", right_query."comment#3", right_query."comment.content#0", right_query."comment.creationDate#0", right_query."comment.id#0", right_query."_e221#0" FROM
    q5 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."_e219#0" = right_query."_e219#0"),
q10 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "comment#3", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e222#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "person#16",
    toTable."p_personid" AS "person.id#16", toTable."p_firstname" AS "person.firstName#4", toTable."p_lastname" AS "person.lastName#4"
    FROM "message" fromTable
      JOIN "person" toTable ON (fromTable."m_creatorid" = toTable."p_personid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q11 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", left_query."_e219#0", left_query."_e220#0", left_query."comment#3", left_query."_e221#0", left_query."comment.creationDate#0", left_query."comment.id#0", left_query."comment.content#0", right_query."person.lastName#4", right_query."person.id#16", right_query."person#16", right_query."person.firstName#4", right_query."_e222#0" FROM
    q9 AS left_query
    INNER JOIN
    q10 AS right_query
  ON left_query."comment#3" = right_query."comment#3"),
q12 AS
 (-- AllDifferent
  SELECT * FROM q11 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e222#0" || "_e220#0" || "_e221#0")),
q13 AS
 (-- Projection
  SELECT "person.id#16" AS "personId#2", "person.firstName#4" AS "personFirstName#2", "person.lastName#4" AS "personLastName#2", "comment.creationDate#0" AS "commentCreationDate#0", "comment.id#0" AS "commentId#0", "comment.content#0" AS "commentContent#0"
    FROM q12 AS subquery),
q14 AS
 (-- SortAndTop
  SELECT * FROM q13 AS subquery
    ORDER BY "commentCreationDate#0" DESC NULLS LAST, ("commentId#0")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#2" AS "personId", "personFirstName#2" AS "personFirstName", "personLastName#2" AS "personLastName", "commentCreationDate#0" AS "commentCreationDate", "commentId#0" AS "commentId", "commentContent#0" AS "commentContent"
  FROM q14 AS subquery