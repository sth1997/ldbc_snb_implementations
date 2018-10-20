WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "n#0",
    "p_firstname" AS "n.firstName#0",
    "p_lastname" AS "n.lastName#0",
    "p_birthday" AS "n.birthday#0",
    "p_locationip" AS "n.locationIP#0",
    "p_browserused" AS "n.browserUsed#0",
    "p_gender" AS "n.gender#0",
    "p_creationdate" AS "n.creationDate#0",
    "p_personid" AS "n.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("n.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "p_personid" AS "n#0", ROW("p_personid", "p_placeid")::edge_type AS "_e248#0", "p_placeid" AS "p#0",
    "place"."pl_placeid" AS "p.id#0"
    FROM "person"
      JOIN "place" ON ("person"."p_placeid" = "place"."pl_placeid")),
q3 AS
 (-- EquiJoinLike
  SELECT left_query."n#0", left_query."n.firstName#0", left_query."n.lastName#0", left_query."n.birthday#0", left_query."n.locationIP#0", left_query."n.browserUsed#0", left_query."n.gender#0", left_query."n.creationDate#0", left_query."n.id#0", right_query."_e248#0", right_query."p#0", right_query."p.id#0" FROM
    q1 AS left_query
    INNER JOIN
    q2 AS right_query
  ON left_query."n#0" = right_query."n#0"),
-- q4 (AllDifferent): q3
q5 AS
 (-- Projection
  SELECT "n.firstName#0" AS "firstName#0", "n.lastName#0" AS "lastName#0", "n.birthday#0" AS "birthday#0", "n.locationIP#0" AS "locationIP#0", "n.browserUsed#0" AS "browserUsed#0", "p.id#0" AS "cityId#0", "n.gender#0" AS "gender#1", "n.creationDate#0" AS "creationDate#0"
    FROM q3 AS subquery)
SELECT "firstName#0" AS "firstName", "lastName#0" AS "lastName", "birthday#0" AS "birthday", "locationIP#0" AS "locationIP", "browserUsed#0" AS "browserUsed", "cityId#0" AS "cityId", "gender#1" AS "gender", "creationDate#0" AS "creationDate"
  FROM q5 AS subquery