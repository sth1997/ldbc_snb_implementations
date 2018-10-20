WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "start#0",
    "p_personid" AS "start.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("start.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "_e219#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e220#0", "m_creatorid" AS "start#0"
    FROM "message"),
q3 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", right_query."_e219#0", right_query."_e220#0" FROM
    q1 AS left_query
    INNER JOIN
    q2 AS right_query
  ON left_query."start#0" = right_query."start#0"),
q4 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "comment#3", ROW("m_messageid", "m_c_replyof")::edge_type AS "_e221#0", "m_c_replyof" AS "_e219#0",
    "message"."m_creationdate" AS "comment.creationDate#0", "message"."m_messageid" AS "comment.id#0", "message"."m_content" AS "comment.content#0"
    FROM "message"),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", left_query."_e219#0", left_query."_e220#0", right_query."comment#3", right_query."comment.content#0", right_query."comment.creationDate#0", right_query."comment.id#0", right_query."_e221#0" FROM
    q3 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."_e219#0" = right_query."_e219#0"),
q6 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "comment#3", ROW("m_messageid", "m_creatorid")::edge_type AS "_e222#0", "m_creatorid" AS "person#16",
    "person"."p_personid" AS "person.id#16", "person"."p_firstname" AS "person.firstName#4", "person"."p_lastname" AS "person.lastName#4"
    FROM "message"
      JOIN "person" ON ("message"."m_creatorid" = "person"."p_personid")),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."start#0", left_query."start.id#0", left_query."_e219#0", left_query."_e220#0", left_query."comment#3", left_query."_e221#0", left_query."comment.creationDate#0", left_query."comment.id#0", left_query."comment.content#0", right_query."person.lastName#4", right_query."person.id#16", right_query."person#16", right_query."person.firstName#4", right_query."_e222#0" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."comment#3" = right_query."comment#3"),
q8 AS
 (-- AllDifferent
  SELECT * FROM q7 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e222#0" || "_e220#0" || "_e221#0")),
q9 AS
 (-- Projection
  SELECT "person.id#16" AS "personId#2", "person.firstName#4" AS "personFirstName#2", "person.lastName#4" AS "personLastName#2", "comment.creationDate#0" AS "commentCreationDate#0", "comment.id#0" AS "commentId#0", "comment.content#0" AS "commentContent#0"
    FROM q8 AS subquery),
q10 AS
 (-- SortAndTop
  SELECT * FROM q9 AS subquery
    ORDER BY "commentCreationDate#0" DESC NULLS LAST, ("commentId#0")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#2" AS "personId", "personFirstName#2" AS "personFirstName", "personLastName#2" AS "personLastName", "commentCreationDate#0" AS "commentCreationDate", "commentId#0" AS "commentId", "commentContent#0" AS "commentContent"
  FROM q10 AS subquery