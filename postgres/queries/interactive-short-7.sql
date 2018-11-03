WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#4",
    "m_messageid" AS "m.id#4"
  FROM message
  WHERE (message."m_c_replyof" IS NULL)),
q1 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#4",
    "m_messageid" AS "m.id#4"
  FROM message
  WHERE (message."m_c_replyof" IS NOT NULL)),
q2 AS
 (-- UnionAll
  SELECT "m#4", "m.id#4" FROM q0
  UNION ALL
  SELECT "m#4", "m.id#4" FROM q1),
q3 AS
 (-- Selection
  SELECT * FROM q2 AS subquery
  WHERE ("m.id#4" = :messageId)),
q4 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "c#2", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "_e257#0", ROW(6, fromTable."m_c_replyof")::vertex_type AS "m#4",
    fromTable."m_messageid" AS "c.id#2", fromTable."m_content" AS "c.content#0", fromTable."m_creationdate" AS "c.creationDate#0"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NULL)),
q5 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "c#2", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "_e257#0", ROW(6, fromTable."m_c_replyof")::vertex_type AS "m#4",
    fromTable."m_messageid" AS "c.id#2", fromTable."m_content" AS "c.content#0", fromTable."m_creationdate" AS "c.creationDate#0"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NOT NULL)),
q6 AS
 (-- UnionAll
  SELECT "c#2", "_e257#0", "m#4", "c.id#2", "c.content#0", "c.creationDate#0" FROM q4
  UNION ALL
  SELECT "c#2", "_e257#0", "m#4", "c.id#2", "c.content#0", "c.creationDate#0" FROM q5),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", right_query."c.content#0", right_query."c#2", right_query."_e257#0", right_query."c.id#2", right_query."c.creationDate#0" FROM
    q3 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."m#4" = right_query."m#4"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "c#2", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e258#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "p#4",
    toTable."p_personid" AS "p.id#3", toTable."p_firstname" AS "p.firstName#1", toTable."p_lastname" AS "p.lastName#1"
    FROM "message" fromTable
      JOIN "person" toTable ON (fromTable."m_creatorid" = toTable."p_personid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", left_query."c#2", left_query."_e257#0", left_query."c.id#2", left_query."c.content#0", left_query."c.creationDate#0", right_query."p#4", right_query."p.lastName#1", right_query."p.firstName#1", right_query."p.id#3", right_query."_e258#0" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."c#2" = right_query."c#2"),
q10 AS
 (-- AllDifferent
  SELECT * FROM q9 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e258#0" || "_e257#0")),
q11 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "m#4", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e259#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "a#1"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q12 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "m#4", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e259#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "a#1"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q13 AS
 (-- UnionAll
  SELECT "m#4", "_e259#0", "a#1" FROM q11
  UNION ALL
  SELECT "m#4", "_e259#0", "a#1" FROM q12),
q14 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "a#1", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "r#1", ROW(0, edgeTable."k_person2id")::vertex_type AS "p#4"
    FROM "knows" edgeTable),
q15 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "p#4", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "r#1", ROW(0, edgeTable."k_person2id")::vertex_type AS "a#1"
    FROM "knows" edgeTable),
q16 AS
 (-- UnionAll
  SELECT "a#1", "r#1", "p#4" FROM q14
  UNION ALL
  SELECT "a#1", "r#1", "p#4" FROM q15),
q17 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."_e259#0", left_query."a#1", right_query."r#1", right_query."p#4" FROM
    q13 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."a#1" = right_query."a#1"),
q18 AS
 (-- AllDifferent
  SELECT * FROM q17 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e259#0" || "r#1")),
q19 AS
 (-- EquiJoinLike
  SELECT left_query."m#4", left_query."m.id#4", left_query."c#2", left_query."_e257#0", left_query."c.id#2", left_query."c.content#0", left_query."c.creationDate#0", left_query."_e258#0", left_query."p#4", left_query."p.id#3", left_query."p.firstName#1", left_query."p.lastName#1", right_query."_e259#0", right_query."r#1", right_query."a#1" FROM
    q10 AS left_query
    LEFT OUTER JOIN
    q18 AS right_query
  ON left_query."m#4" = right_query."m#4" AND
     left_query."p#4" = right_query."p#4"),
q20 AS
 (-- Projection
  SELECT "c.id#2" AS "commentId#1", "c.content#0" AS "commentContent#1", "c.creationDate#0" AS "commentCreationDate#1", "p.id#3" AS "replyAuthorId#0", "p.firstName#1" AS "replyAuthorFirstName#0", "p.lastName#1" AS "replyAuthorLastName#0", CASE WHEN ("r#1" = NULL) THEN false
              ELSE true
         END AS "replyAuthorKnowsOriginalMessageAuthor#0"
    FROM q19 AS subquery),
q21 AS
 (-- SortAndTop
  SELECT * FROM q20 AS subquery
    ORDER BY "commentCreationDate#1" DESC NULLS LAST, "replyAuthorId#0" ASC NULLS FIRST)
SELECT "commentId#1" AS "commentId", "commentContent#1" AS "commentContent", "commentCreationDate#1" AS "commentCreationDate", "replyAuthorId#0" AS "replyAuthorId", "replyAuthorFirstName#0" AS "replyAuthorFirstName", "replyAuthorLastName#0" AS "replyAuthorLastName", "replyAuthorKnowsOriginalMessageAuthor#0" AS "replyAuthorKnowsOriginalMessageAuthor"
  FROM q21 AS subquery