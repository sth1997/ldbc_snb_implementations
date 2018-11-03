WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "_e240#0",
    "p_personid" AS "_e240.id#0"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("_e240.id#0" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "_e240#0", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "_e241#0", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#8",
    toTable."p_personid" AS "friend.id#6", toTable."p_firstname" AS "friend.firstName#5", toTable."p_lastname" AS "friend.lastName#6"
    FROM "knows" edgeTable
      JOIN "person" toTable ON (edgeTable."k_person2id" = toTable."p_personid")),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#8", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "_e241#0", ROW(0, edgeTable."k_person2id")::vertex_type AS "_e240#0",
    fromTable."p_personid" AS "friend.id#6", fromTable."p_firstname" AS "friend.firstName#5", fromTable."p_lastname" AS "friend.lastName#6"
    FROM "knows" edgeTable
      JOIN "person" fromTable ON (fromTable."p_personid" = edgeTable."k_person1id")),
q4 AS
 (-- UnionAll
  SELECT "_e240#0", "_e241#0", "friend#8", "friend.id#6", "friend.firstName#5", "friend.lastName#6" FROM q2
  UNION ALL
  SELECT "_e240#0", "_e241#0", "friend#8", "friend.id#6", "friend.firstName#5", "friend.lastName#6" FROM q3),
q5 AS
 (-- EquiJoinLike
  SELECT left_query."_e240#0", left_query."_e240.id#0", right_query."_e241#0", right_query."friend.id#6", right_query."friend.lastName#6", right_query."friend#8", right_query."friend.firstName#5" FROM
    q1 AS left_query
    INNER JOIN
    q4 AS right_query
  ON left_query."_e240#0" = right_query."_e240#0"),
q6 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "comment#4", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e242#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#8"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."_e240#0", left_query."_e240.id#0", left_query."_e241#0", left_query."friend#8", left_query."friend.id#6", left_query."friend.firstName#5", left_query."friend.lastName#6", right_query."comment#4", right_query."_e242#0" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#8" = right_query."friend#8"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "comment#4", ROW(10, fromTable."m_messageid", fromTable."m_c_replyof")::edge_type AS "_e244#0", ROW(6, fromTable."m_c_replyof")::vertex_type AS "_e243#0"
    FROM "message" fromTable
      JOIN "message" toTable ON (fromTable."m_c_replyof" = toTable."m_messageid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."m_c_replyof" IS NULL)),
q9 AS
 (-- EquiJoinLike
  SELECT left_query."_e240#0", left_query."_e240.id#0", left_query."_e241#0", left_query."friend#8", left_query."friend.id#6", left_query."friend.firstName#5", left_query."friend.lastName#6", left_query."comment#4", left_query."_e242#0", right_query."_e244#0", right_query."_e243#0" FROM
    q7 AS left_query
    INNER JOIN
    q8 AS right_query
  ON left_query."comment#4" = right_query."comment#4"),
q10 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, edgeTable."mt_messageid")::vertex_type AS "_e243#0", ROW(6, edgeTable."mt_messageid", edgeTable."mt_tagid")::edge_type AS "_e245#0", ROW(4, edgeTable."mt_tagid")::vertex_type AS "tag#8",
    toTable."t_name" AS "tag.name#8"
    FROM "message_tag" edgeTable
      JOIN "tag" toTable ON (edgeTable."mt_tagid" = toTable."t_tagid")
      JOIN "message" fromTable ON (fromTable."m_messageid" = edgeTable."mt_messageid")
  WHERE (fromTable."m_c_replyof" IS NULL)),
q11 AS
 (-- EquiJoinLike
  SELECT left_query."_e240#0", left_query."_e240.id#0", left_query."_e241#0", left_query."friend#8", left_query."friend.id#6", left_query."friend.firstName#5", left_query."friend.lastName#6", left_query."comment#4", left_query."_e242#0", left_query."_e244#0", left_query."_e243#0", right_query."_e245#0", right_query."tag#8", right_query."tag.name#8" FROM
    q9 AS left_query
    INNER JOIN
    q10 AS right_query
  ON left_query."_e243#0" = right_query."_e243#0"),
q12 AS
 (-- GetEdgesWithGTop
  SELECT ROW(4, fromTable."t_tagid")::vertex_type AS "tag#8", ROW(2, fromTable."t_tagid", fromTable."t_tagclassid")::edge_type AS "_e246#0", ROW(5, fromTable."t_tagclassid")::vertex_type AS "tagClass#1",
    toTable."tc_name" AS "tagClass.name#2"
    FROM "tag" fromTable
      JOIN "tagclass" toTable ON (fromTable."t_tagclassid" = toTable."tc_tagclassid")),
q13 AS
 (-- GetEdgesWithGTop
  SELECT ROW(5, fromTable."tc_tagclassid")::vertex_type AS "current_from", ROW(7, fromTable."tc_tagclassid", fromTable."tc_subclassoftagclassid")::edge_type AS "edge_id", ROW(5, fromTable."tc_subclassoftagclassid")::vertex_type AS "baseTagClass#0"
    FROM "tagclass" fromTable),
q14 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q12)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e247#0",
        "tagClass#1" AS next_from,
        "tagClass#1" AS "baseTagClass#0"
      FROM left_query
    )
    UNION ALL
    SELECT
      "tag#8", "_e246#0", "tagClass#1", "tagClass.name#2",
      ("_e247#0"|| edge_id) AS "_e247#0",
      edges."baseTagClass#0" AS nextFrom,
      edges."baseTagClass#0"
    FROM (SELECT * FROM q13) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e247#0") -- edge uniqueness
           AND next_from = current_from
  )
  SELECT
    "tag#8",
    "_e246#0",
    "tagClass#1",
    "tagClass.name#2",
    "_e247#0",
    "baseTagClass#0"
  FROM recursive_table),
q15 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(5, tc_tagclassid)::vertex_type AS "baseTagClass#0",
    "tc_name" AS "baseTagClass.name#0"
  FROM tagclass),
q16 AS
 (-- EquiJoinLike
  SELECT left_query."tag#8", left_query."_e246#0", left_query."tagClass#1", left_query."tagClass.name#2", left_query."_e247#0", left_query."baseTagClass#0", right_query."baseTagClass.name#0" FROM
    q14 AS left_query
    INNER JOIN
    q15 AS right_query
  ON left_query."baseTagClass#0" = right_query."baseTagClass#0"),
q17 AS
 (-- EquiJoinLike
  SELECT left_query."_e240#0", left_query."_e240.id#0", left_query."_e241#0", left_query."friend#8", left_query."friend.id#6", left_query."friend.firstName#5", left_query."friend.lastName#6", left_query."comment#4", left_query."_e242#0", left_query."_e244#0", left_query."_e243#0", left_query."_e245#0", left_query."tag#8", left_query."tag.name#8", right_query."baseTagClass#0", right_query."tagClass.name#2", right_query."_e246#0", right_query."_e247#0", right_query."tagClass#1", right_query."baseTagClass.name#0" FROM
    q11 AS left_query
    INNER JOIN
    q16 AS right_query
  ON left_query."tag#8" = right_query."tag#8"),
q18 AS
 (-- AllDifferent
  SELECT * FROM q17 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e244#0" || "_e247#0" || "_e245#0" || "_e242#0" || "_e241#0" || "_e246#0")),
q19 AS
 (-- Selection
  SELECT * FROM q18 AS subquery
  WHERE (("tagClass.name#2" = :tagClassName) OR ("baseTagClass.name#0" = :tagClassName))),
q20 AS
 (-- Grouping
  SELECT "friend.id#6" AS "personId#5", "friend.firstName#5" AS "personFirstName#5", "friend.lastName#6" AS "personLastName#5", array_agg(DISTINCT "tag.name#8") AS "tagNames#0", count(DISTINCT "comment#4") AS "replyCount#1"
    FROM q19 AS subquery
  GROUP BY "friend.id#6", "friend.firstName#5", "friend.lastName#6"),
q21 AS
 (-- SortAndTop
  SELECT * FROM q20 AS subquery
    ORDER BY "replyCount#1" DESC NULLS LAST, ("personId#5")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#5" AS "personId", "personFirstName#5" AS "personFirstName", "personLastName#5" AS "personLastName", "tagNames#0" AS "tagNames", "replyCount#1" AS "replyCount"
  FROM q21 AS subquery