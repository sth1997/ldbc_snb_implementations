WITH
q0 AS
 (-- GetVertices
  SELECT
    p_personid AS "person#13",
    "p_personid" AS "person.id#13"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#13" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "person#13", ROW("k_person1id", "k_person2id")::edge_type AS "_e201#0", "k_person2id" AS "_e200#0"
    FROM "knows"),
q3 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "_e200#0", ROW("k_person1id", "k_person2id")::edge_type AS "_e201#0", "k_person2id" AS "person#13"
    FROM "knows"),
q4 AS
 (-- UnionAll
  SELECT * FROM q2
  UNION ALL
  SELECT "person#13", "_e201#0", "_e200#0" FROM q3),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."person.id#13", right_query."_e201#0", right_query."_e200#0" FROM
    q1 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."person#13" = right_query."person#13"),
q6 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "post#4", ROW("m_messageid", "m_creatorid")::edge_type AS "_e202#0", "m_creatorid" AS "_e200#0",
    "message"."m_creationdate" AS "post.creationDate#1"
    FROM "message"),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."person.id#13", left_query."_e201#0", left_query."_e200#0", right_query."post#4", right_query."_e202#0", right_query."post.creationDate#1" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."_e200#0" = right_query."_e200#0"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "post#4", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e203#0", "mt_tagid" AS "tag#7",
    "tag"."t_name" AS "tag.name#7"
    FROM "message_tag"
      JOIN "tag" ON ("message_tag"."mt_tagid" = "tag"."t_tagid")),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."person.id#13", left_query."_e201#0", left_query."_e200#0", left_query."post#4", left_query."_e202#0", left_query."post.creationDate#1", right_query."_e203#0", right_query."tag#7", right_query."tag.name#7" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."post#4" = right_query."post#4"),
q10 AS
 (-- AllDifferent
  SELECT * FROM q9 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e201#0" || "_e202#0" || "_e203#0")),
q11 AS
 (-- Selection
  SELECT * FROM q10 AS subquery
  WHERE (("post.creationDate#1" >= :startDate) AND ("post.creationDate#1" < :endDate))),
q12 AS
 (-- Grouping
  SELECT "person#13" AS "person#13", count("post#4") AS "postsOnTag#0", "tag#7" AS "tag#7", "tag.name#7" AS "tag.name#7"
    FROM q11 AS subquery
  GROUP BY "person#13", "tag#7", "tag.name#7"),
q13 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "person#13", ROW("k_person1id", "k_person2id")::edge_type AS "_e205#0", "k_person2id" AS "_e204#0"
    FROM "knows"),
q14 AS
 (-- GetEdgesWithGTop
  SELECT "k_person1id" AS "_e204#0", ROW("k_person1id", "k_person2id")::edge_type AS "_e205#0", "k_person2id" AS "person#13"
    FROM "knows"),
q15 AS
 (-- UnionAll
  SELECT * FROM q13
  UNION ALL
  SELECT "person#13", "_e205#0", "_e204#0" FROM q14),
q16 AS
 (-- GetEdgesWithGTop
  SELECT "m_messageid" AS "oldPost#0", ROW("m_messageid", "m_creatorid")::edge_type AS "_e206#0", "m_creatorid" AS "_e204#0",
    "message"."m_creationdate" AS "oldPost.creationDate#0"
    FROM "message"),
q17 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."_e205#0", left_query."_e204#0", right_query."oldPost#0", right_query."_e206#0", right_query."oldPost.creationDate#0" FROM
    q15 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."_e204#0" = right_query."_e204#0"),
q18 AS
 (-- GetEdgesWithGTop
  SELECT "mt_messageid" AS "oldPost#0", ROW("mt_messageid", "mt_tagid")::edge_type AS "_e207#0", "mt_tagid" AS "tag#7"
    FROM "message_tag"),
q19 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."_e205#0", left_query."_e204#0", left_query."oldPost#0", left_query."_e206#0", left_query."oldPost.creationDate#0", right_query."_e207#0", right_query."tag#7" FROM
    q17 AS left_query
    INNER JOIN
    q18 AS right_query
  ON left_query."oldPost#0" = right_query."oldPost#0"),
q20 AS
 (-- AllDifferent
  SELECT * FROM q19 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e205#0" || "_e207#0" || "_e206#0")),
q21 AS
 (-- EquiJoinLike
  SELECT left_query."person#13", left_query."postsOnTag#0", left_query."tag#7", left_query."tag.name#7", right_query."_e205#0", right_query."oldPost#0", right_query."_e204#0", right_query."_e207#0", right_query."_e206#0", right_query."oldPost.creationDate#0" FROM
    q12 AS left_query
    LEFT OUTER JOIN
    q20 AS right_query
  ON left_query."person#13" = right_query."person#13" AND
     left_query."tag#7" = right_query."tag#7" AND
     ("oldPost.creationDate#0" < :startDate)),
q22 AS
 (-- Grouping
  SELECT "person#13" AS "person#13", "postsOnTag#0" AS "postsOnTag#0", "tag#7" AS "tag#7", count("oldPost#0") AS "cp#0", "tag.name#7" AS "tag.name#7"
    FROM q21 AS subquery
  GROUP BY "person#13", "postsOnTag#0", "tag#7", "tag.name#7"),
q23 AS
 (-- Selection
  SELECT * FROM q22 AS subquery
  WHERE ("cp#0" = 0)),
q24 AS
 (-- Grouping
  SELECT "tag.name#7" AS "tagName#1", sum("postsOnTag#0") AS "postCount#2"
    FROM q23 AS subquery
  GROUP BY "tag.name#7"),
q25 AS
 (-- SortAndTop
  SELECT * FROM q24 AS subquery
    ORDER BY "postCount#2" DESC NULLS LAST, "tagName#1" ASC NULLS FIRST
    LIMIT 10)
SELECT "tagName#1" AS "tagName", "postCount#2" AS "postCount"
  FROM q25 AS subquery