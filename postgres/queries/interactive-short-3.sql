WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "n#1",
    "p_personid" AS "n.id#1"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("n.id#1" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "n#1", ROW("k_person1id", "k_person2id")::edge_type AS "r#0", "k_person2id" AS "friend#9",
    "person"."p_personid" AS "friend.id#7", "person"."p_firstname" AS "friend.firstName#6", "person"."p_lastname" AS "friend.lastName#7", "knows"."k_creationdate" AS "r.creationDate#0"
    FROM "knows"
      JOIN "person" ON ("knows"."k_person1id" = "person"."p_personid")),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "friend#9", ROW("k_person1id", "k_person2id")::edge_type AS "r#0", "k_person2id" AS "n#1",
    "person"."p_personid" AS "friend.id#7", "person"."p_firstname" AS "friend.firstName#6", "person"."p_lastname" AS "friend.lastName#7", "knows"."k_creationdate" AS "r.creationDate#0"
    FROM "knows"
      JOIN "person" ON ("knows"."k_person1id" = "person"."p_personid")),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "n#1", "r#0", "friend#9", "friend.id#7", "friend.firstName#6", "friend.lastName#7", "r.creationDate#0" FROM q3),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."n#1", left_query."n.id#1", right_query."friend#9", right_query."friend.firstName#6", right_query."r.creationDate#0", right_query."friend.lastName#7", right_query."r#0", right_query."friend.id#7" FROM
    q1 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."n#1" = right_query."n#1"),
-- q6 (AllDifferent): q5
q7 AS
 (-- Projection
  SELECT "friend.id#7" AS "personId#6", "friend.firstName#6" AS "firstName#1", "friend.lastName#7" AS "lastName#1", "r.creationDate#0" AS "friendshipCreationDate#0"
    FROM q5 AS subquery),
q8 AS
 (-- SortAndTop
  SELECT * FROM q7 AS subquery
    ORDER BY "friendshipCreationDate#0" DESC NULLS LAST, ("personId#6")::BIGINT ASC NULLS FIRST)
SELECT "personId#6" AS "personId", "firstName#1" AS "firstName", "lastName#1" AS "lastName", "friendshipCreationDate#0" AS "friendshipCreationDate"
  FROM q8 AS subquery