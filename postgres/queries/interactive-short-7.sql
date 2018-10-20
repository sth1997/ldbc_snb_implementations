WITH
q0 AS
 (-- GetVertices
  SELECT
    m_messageid AS "m#4",
    "m_messageid" AS "m.id#4"
  FROM message),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("m.id#4" = :messageId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "c#2", ROW("m_messageid", "m_c_replyof")::edge_type AS "_e257#0", "m_c_replyof" AS "m#4",
    "message"."m_messageid" AS "c.id#2", "message"."m_content" AS "c.content#0", "message"."m_creationdate" AS "c.creationDate#0"
    FROM "message"),
q3 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", right_query."c.content#0", right_query."c#2", right_query."_e257#0", right_query."c.id#2", right_query."c.creationDate#0" FROM
    q1 AS left_query
    INNER JOIN
    q2 AS right_query
  ON left_query."m#4" = right_query."m#4"),
q4 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "c#2", ROW("m_messageid", "m_creatorid")::edge_type AS "_e258#0", "m_creatorid" AS "p#4",
    "person"."p_personid" AS "p.id#3", "person"."p_firstname" AS "p.firstName#1", "person"."p_lastname" AS "p.lastName#1"
    FROM "message"
      JOIN "person" ON ("message"."m_creatorid" = "person"."p_personid")),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", left_query."c#2", left_query."_e257#0", left_query."c.id#2", left_query."c.content#0", left_query."c.creationDate#0", right_query."p#4", right_query."p.lastName#1", right_query."p.firstName#1", right_query."p.id#3", right_query."_e258#0" FROM
    q3 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."c#2" = right_query."c#2"),
q6 AS
 (-- AllDifferent
  SELECT * FROM q5 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e258#0" || "_e257#0")),
q7 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "m#4", ROW("m_messageid", "m_creatorid")::edge_type AS "_e259#0", "m_creatorid" AS "a#1"
    FROM "message"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "a#1", ROW("k_person1id", "k_person2id")::edge_type AS "r#1", "k_person2id" AS "p#4"
    FROM "knows"),
q9 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "p#4", ROW("k_person1id", "k_person2id")::edge_type AS "r#1", "k_person2id" AS "a#1"
    FROM "knows"),
q10 AS
 (-- UnionAll
  SELECT * FROM q8
  UNION ALL
  SELECT "a#1", "r#1", "p#4" FROM q9),
q11 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."_e259#0", left_query."a#1", right_query."r#1", right_query."p#4" FROM
    q7 AS left_query
    INNER JOIN
    q10 AS right_query
  ON left_query."a#1" = right_query."a#1"),
q12 AS
 (-- AllDifferent
  SELECT * FROM q11 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e259#0" || "r#1")),
q13 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", left_query."c#2", left_query."_e257#0", left_query."c.id#2", left_query."c.content#0", left_query."c.creationDate#0", left_query."_e258#0", left_query."p#4", left_query."p.id#3", left_query."p.firstName#1", left_query."p.lastName#1", right_query."_e259#0", right_query."r#1", right_query."a#1" FROM
    q6 AS left_query
    LEFT OUTER JOIN
    q12 AS right_query
  ON left_query."m#4" = right_query."m#4" AND
     left_query."p#4" = right_query."p#4"),
q14 AS
 (-- Projection
  SELECT "c.id#2" AS "commentId#1", "c.content#0" AS "commentContent#1", "c.creationDate#0" AS "commentCreationDate#1", "p.id#3" AS "replyAuthorId#0", "p.firstName#1" AS "replyAuthorFirstName#0", "p.lastName#1" AS "replyAuthorLastName#0", CASE WHEN ("r#1" = NULL) THEN false
              ELSE true
         END AS "replyAuthorKnowsOriginalMessageAuthor#0"
    FROM q13 AS subquery),
q15 AS
 (-- SortAndTop
  SELECT * FROM q14 AS subquery
    ORDER BY "commentCreationDate#1" DESC NULLS LAST, "replyAuthorId#0" ASC NULLS FIRST)
SELECT "commentId#1" AS "commentId", "commentContent#1" AS "commentContent", "commentCreationDate#1" AS "commentCreationDate", "replyAuthorId#0" AS "replyAuthorId", "replyAuthorFirstName#0" AS "replyAuthorFirstName", "replyAuthorLastName#0" AS "replyAuthorLastName", "replyAuthorKnowsOriginalMessageAuthor#0" AS "replyAuthorKnowsOriginalMessageAuthor"
  FROM q15 AS subquery