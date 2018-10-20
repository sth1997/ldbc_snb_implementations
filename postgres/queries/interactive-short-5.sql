WITH
q0 AS
 (-- GetVertices
  SELECT
    m_messageid AS "m#2",
    "m_messageid" AS "m.id#2"
  FROM message),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("m.id#2" = :messageId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "m#2", ROW("m_messageid", "m_creatorid")::edge_type AS "_e253#0", "m_creatorid" AS "p#2",
    "person"."p_personid" AS "p.id#2", "person"."p_firstname" AS "p.firstName#0", "person"."p_lastname" AS "p.lastName#0"
    FROM "message"
      JOIN "person" ON ("message"."m_creatorid" = "person"."p_personid")),
q3 AS
 (-- EquiJoinLike
  SELECT left_query."m#2", left_query."m.id#2", right_query."p.firstName#0", right_query."p.lastName#0", right_query."p#2", right_query."_e253#0", right_query."p.id#2" FROM
    q1 AS left_query
    INNER JOIN
    q2 AS right_query
  ON left_query."m#2" = right_query."m#2"),
-- q4 (AllDifferent): q3
q5 AS
 (-- Projection
  SELECT "p.id#2" AS "personId#7", "p.firstName#0" AS "firstName#2", "p.lastName#0" AS "lastName#2"
    FROM q3 AS subquery)
SELECT "personId#7" AS "personId", "firstName#2" AS "firstName", "lastName#2" AS "lastName"
  FROM q5 AS subquery