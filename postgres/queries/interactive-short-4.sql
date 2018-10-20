WITH
q0 AS
 (-- GetVertices
  SELECT
    m_messageid AS "m#1",
    "m_creationdate" AS "m.creationDate#1",
    "m_content" AS "m.content#1",
    "m_ps_imagefile" AS "m.imageFile#1",
    "m_messageid" AS "m.id#1"
  FROM message),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("m.id#1" = :messageId)),
-- q2 (AllDifferent): q1
q3 AS
 (-- Projection
  SELECT "m.creationDate#1" AS "messageCreationDate#1", CASE WHEN ("m.content#1" IS NOT NULL = true) THEN "m.content#1"
              ELSE "m.imageFile#1"
         END AS "messageContent#1"
    FROM q1 AS subquery)
SELECT "messageCreationDate#1" AS "messageCreationDate", "messageContent#1" AS "messageContent"
  FROM q3 AS subquery