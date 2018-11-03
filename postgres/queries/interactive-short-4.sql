WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#1",
    "m_creationdate" AS "m.creationDate#1",
    "m_content" AS "m.content#1",
    "m_ps_imagefile" AS "m.imageFile#1",
    "m_messageid" AS "m.id#1"
  FROM message
  WHERE (message."m_c_replyof" IS NULL)),
q1 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(6, m_messageid)::vertex_type AS "m#1",
    "m_creationdate" AS "m.creationDate#1",
    "m_content" AS "m.content#1",
    "m_messageid" AS "m.id#1"
  FROM message
  WHERE (message."m_c_replyof" IS NOT NULL)),
q2 AS
 (-- UnionAll
  SELECT "m#1", "m.creationDate#1", "m.content#1", "m.imageFile#1", "m.id#1" FROM q0
  UNION ALL
  SELECT "m#1", "m.creationDate#1", "m.content#1", NULL AS "m.imageFile#1", "m.id#1" FROM q1),
q3 AS
 (-- Selection
  SELECT * FROM q2 AS subquery
  WHERE ("m.id#1" = :messageId)),
-- q4 (AllDifferent): q3
q5 AS
 (-- Projection
  SELECT "m.creationDate#1" AS "messageCreationDate#1", CASE WHEN ("m.content#1" IS NOT NULL = true) THEN "m.content#1"
              ELSE "m.imageFile#1"
         END AS "messageContent#1"
    FROM q3 AS subquery)
SELECT "messageCreationDate#1" AS "messageCreationDate", "messageContent#1" AS "messageContent"
  FROM q5 AS subquery