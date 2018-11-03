WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "_e186#0",
    "p_personid" AS "_e186.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("_e186.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "_e186#0", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "_e187#0", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#2",
    toTable."p_personid" AS "friend.id#2", toTable."p_firstname" AS "friend.firstName#1", toTable."p_lastname" AS "friend.lastName#2"
    FROM "knows" edgeTable
      JOIN "person" toTable ON (edgeTable."k_person2id" = toTable."p_personid")),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#2", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "_e187#0", ROW(0, edgeTable."k_person2id")::vertex_type AS "_e186#0",
    fromTable."p_personid" AS "friend.id#2", fromTable."p_firstname" AS "friend.firstName#1", fromTable."p_lastname" AS "friend.lastName#2"
    FROM "knows" edgeTable
      JOIN "person" fromTable ON (fromTable."p_personid" = edgeTable."k_person1id")),
q4 AS
 (-- UnionAll
  SELECT "_e186#0", "_e187#0", "friend#2", "friend.id#2", "friend.firstName#1", "friend.lastName#2" FROM q2
  UNION ALL
  SELECT "_e186#0", "_e187#0", "friend#2", "friend.id#2", "friend.firstName#1", "friend.lastName#2" FROM q3),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."_e186#0", left_query."_e186.id#0", right_query."friend#2", right_query."friend.id#2", right_query."_e187#0", right_query."friend.lastName#2", right_query."friend.firstName#1" FROM
    q1 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."_e186#0" = right_query."_e186#0"),
q6 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "message#17", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e188#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#2",
    fromTable."m_messageid" AS "message.id#2", fromTable."m_content" AS "message.content#2", fromTable."m_ps_imagefile" AS "message.imageFile#0", fromTable."m_creationdate" AS "message.creationDate#13"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q7 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "message#17", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e188#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#2",
    fromTable."m_messageid" AS "message.id#2", fromTable."m_content" AS "message.content#2", fromTable."m_creationdate" AS "message.creationDate#13"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q8 AS
 (-- UnionAll
  SELECT "message#17", "_e188#0", "friend#2", "message.id#2", "message.content#2", "message.imageFile#0", "message.creationDate#13" FROM q6
  UNION ALL
  SELECT "message#17", "_e188#0", "friend#2", "message.id#2", "message.content#2", NULL AS "message.imageFile#0", "message.creationDate#13" FROM q7),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."_e186#0", left_query."_e186.id#0", left_query."_e187#0", left_query."friend#2", left_query."friend.id#2", left_query."friend.firstName#1", left_query."friend.lastName#2", right_query."message#17", right_query."message.id#2", right_query."message.imageFile#0", right_query."_e188#0", right_query."message.creationDate#13", right_query."message.content#2" FROM
    q5 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."friend#2" = right_query."friend#2"),
q10 AS
 (-- AllDifferent
  SELECT * FROM q9 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e188#0" || "_e187#0")),
q11 AS
 (-- Selection
  SELECT * FROM q10 AS subquery
  WHERE ("message.creationDate#13" <= :maxDate)),
q12 AS
 (-- Projection
  SELECT "friend.id#2" AS "personId#0", "friend.firstName#1" AS "personFirstName#0", "friend.lastName#2" AS "personLastName#0", "message.id#2" AS "postOrCommentId#0", CASE WHEN ("message.content#2" IS NOT NULL = true) THEN "message.content#2"
              ELSE "message.imageFile#0"
         END AS "postOrCommentContent#0", "message.creationDate#13" AS "postOrCommentCreationDate#0"
    FROM q11 AS subquery),
q13 AS
 (-- SortAndTop
  SELECT * FROM q12 AS subquery
    ORDER BY "postOrCommentCreationDate#0" DESC NULLS LAST, ("postOrCommentId#0")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#0" AS "personId", "personFirstName#0" AS "personFirstName", "personLastName#0" AS "personLastName", "postOrCommentId#0" AS "postOrCommentId", "postOrCommentContent#0" AS "postOrCommentContent", "postOrCommentCreationDate#0" AS "postOrCommentCreationDate"
  FROM q13 AS subquery