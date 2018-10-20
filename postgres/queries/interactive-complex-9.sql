WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "_e223#0",
    "p_personid" AS "_e223.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("_e223.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "current_from", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "friend#6"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#6", ROW("k_person1id", "k_person2id")::edge_type AS "edge_id", "k_person2id" AS "current_from"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#6" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e224#0",
        "_e223#0" AS next_from,
        "_e223#0" AS "friend#6"
      FROM left_query
    )
    UNION ALL
    SELECT
      "_e223#0", "_e223.id#0",
      ("_e224#0"|| edge_id) AS "_e224#0",
      edges."friend#6" AS nextFrom,
      edges."friend#6"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e224#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e224#0") < 2
  )
  SELECT
    "_e223#0",
    "_e223.id#0",
    "_e224#0",
    "friend#6"
  FROM recursive_table
  WHERE array_length("_e224#0") >= 1),
q6 AS
 (-- GetVertices
  SELECT
    p_personid AS "friend#6",
    "p_personid" AS "friend.id#4",
    "p_firstname" AS "friend.firstName#3",
    "p_lastname" AS "friend.lastName#4"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."_e223#0", left_query."_e223.id#0", left_query."_e224#0", left_query."friend#6", right_query."friend.id#4", right_query."friend.firstName#3", right_query."friend.lastName#4" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#6" = right_query."friend#6"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "message#18", ROW("m_messageid", "m_creatorid")::edge_type AS "_e225#0", "m_creatorid" AS "friend#6",
    "message"."m_content" AS "message.content#3", "message"."m_ps_imagefile" AS "message.imageFile#1", "message"."m_messageid" AS "message.id#3", "message"."m_creationdate" AS "message.creationDate#14"
    FROM "message"),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."_e223#0", left_query."_e223.id#0", left_query."_e224#0", left_query."friend#6", left_query."friend.id#4", left_query."friend.firstName#3", left_query."friend.lastName#4", right_query."_e225#0", right_query."message#18", right_query."message.id#3", right_query."message.creationDate#14", right_query."message.content#3", right_query."message.imageFile#1" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."friend#6" = right_query."friend#6"),
q10 AS
 (-- AllDifferent
  SELECT * FROM q9 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e224#0" || "_e225#0")),
q11 AS
 (-- Selection
  SELECT * FROM q10 AS subquery
  WHERE ("message.creationDate#14" < :maxDate)),
q12 AS
 (-- Projection
  SELECT "friend.id#4" AS "personId#3", "friend.firstName#3" AS "personFirstName#3", "friend.lastName#4" AS "personLastName#3", "message.id#3" AS "commentOrPostId#0", CASE WHEN ("message.content#3" IS NOT NULL = true) THEN "message.content#3"
              ELSE "message.imageFile#1"
         END AS "commentOrPostContent#0", "message.creationDate#14" AS "commentOrPostCreationDate#0", "message.creationDate#14" AS "message.creationDate#14", "friend.id#4" AS "friend.id#4", "friend.firstName#3" AS "friend.firstName#3", "friend.lastName#4" AS "friend.lastName#4", "message.id#3" AS "message.id#3", "message.content#3" AS "message.content#3", "message.imageFile#1" AS "message.imageFile#1"
    FROM q11 AS subquery),
q13 AS
 (-- SortAndTop
  SELECT * FROM q12 AS subquery
    ORDER BY "message.creationDate#14" DESC NULLS LAST, ("message.id#3")::BIGINT ASC NULLS FIRST
    LIMIT 20),
q14 AS
 (-- Projection
  SELECT "friend.id#4" AS "personId#3", "friend.firstName#3" AS "personFirstName#3", "friend.lastName#4" AS "personLastName#3", "message.id#3" AS "commentOrPostId#0", CASE WHEN ("message.content#3" IS NOT NULL = true) THEN "message.content#3"
              ELSE "message.imageFile#1"
         END AS "commentOrPostContent#0", "message.creationDate#14" AS "commentOrPostCreationDate#0"
    FROM q13 AS subquery)
SELECT "personId#3" AS "personId", "personFirstName#3" AS "personFirstName", "personLastName#3" AS "personLastName", "commentOrPostId#0" AS "commentOrPostId", "commentOrPostContent#0" AS "commentOrPostContent", "commentOrPostCreationDate#0" AS "commentOrPostCreationDate"
  FROM q14 AS subquery