WITH
q0 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "person#12",
    "p_personid" AS "person.id#12"
  FROM person),
q1 AS
 (-- Selection
  SELECT * FROM q0 AS subquery
  WHERE ("person.id#12" = :personId)),
q2 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "current_from", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "friend#3"
    FROM "knows" edgeTable),
q3 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, edgeTable."k_person1id")::vertex_type AS "friend#3", ROW(0, edgeTable."k_person1id", edgeTable."k_person2id")::edge_type AS "edge_id", ROW(0, edgeTable."k_person2id")::vertex_type AS "current_from"
    FROM "knows" edgeTable),
q4 AS
 (-- UnionAll
  SELECT "current_from", "edge_id", "friend#3" FROM q2
  UNION ALL
  SELECT "current_from", "edge_id", "friend#3" FROM q3),
q5 AS
 (-- TransitiveJoin
  WITH RECURSIVE recursive_table AS (
    (
      WITH left_query AS (SELECT * FROM q1)
      SELECT
        *,
        ARRAY [] :: edge_type [] AS "_e189#0",
        "person#12" AS next_from,
        "person#12" AS "friend#3"
      FROM left_query
    )
    UNION ALL
    SELECT
      "person#12", "person.id#12",
      ("_e189#0"|| edge_id) AS "_e189#0",
      edges."friend#3" AS nextFrom,
      edges."friend#3"
    FROM (SELECT * FROM q4) edges
      INNER JOIN recursive_table
        ON edge_id <> ALL ("_e189#0") -- edge uniqueness
           AND next_from = current_from
           AND array_length("_e189#0") < 2
  )
  SELECT
    "person#12",
    "person.id#12",
    "_e189#0",
    "friend#3"
  FROM recursive_table
  WHERE array_length("_e189#0") >= 1),
q6 AS
 (-- GetVerticesWithGTop
  SELECT
    ROW(0, p_personid)::vertex_type AS "friend#3",
    "p_personid" AS "friend.id#3",
    "p_firstname" AS "friend.firstName#2",
    "p_lastname" AS "friend.lastName#3"
  FROM person),
q7 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", right_query."friend.id#3", right_query."friend.firstName#2", right_query."friend.lastName#3" FROM
    q5 AS left_query
    INNER JOIN
    q6 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q8 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e190#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#3",
    fromTable."m_creationdate" AS "messageX.creationDate#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q9 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e190#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#3",
    fromTable."m_creationdate" AS "messageX.creationDate#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q10 AS
 (-- UnionAll
  SELECT "messageX#0", "_e190#0", "friend#3", "messageX.creationDate#0" FROM q8
  UNION ALL
  SELECT "messageX#0", "_e190#0", "friend#3", "messageX.creationDate#0" FROM q9),
q11 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", right_query."messageX#0", right_query."_e190#0", right_query."messageX.creationDate#0" FROM
    q7 AS left_query
    INNER JOIN
    q10 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q12 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q13 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q14 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q12
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q13),
q15 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q16 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q14
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q15),
q17 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q18 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q16
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q17),
q19 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q20 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q18
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q19),
q21 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageX#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e191#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q22 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q20
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q21),
q23 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q24 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q22
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q23),
q25 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q26 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q24
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q25),
q27 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q28 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q26
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q27),
q29 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q30 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q28
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q29),
q31 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q32 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q30
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q31),
q33 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageX#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q34 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q32
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q33),
q35 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageX#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'city')),
q36 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q34
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q35),
q37 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageX#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'country')),
q38 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q36
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q37),
q39 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageX#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e191#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryX#0",
    toTable."pl_name" AS "countryX.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'continent')),
q40 AS
 (-- UnionAll
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q38
  UNION ALL
  SELECT "messageX#0", "_e191#0", "countryX#0", "countryX.name#0" FROM q39),
q41 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", left_query."messageX#0", left_query."_e190#0", left_query."messageX.creationDate#0", right_query."_e191#0", right_query."countryX#0", right_query."countryX.name#0" FROM
    q11 AS left_query
    INNER JOIN
    q40 AS right_query
  ON left_query."messageX#0" = right_query."messageX#0"),
q42 AS
 (-- AllDifferent
  SELECT * FROM q41 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e191#0" || "_e189#0" || "_e190#0")),
q43 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q44 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q45 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q43
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q44),
q46 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q47 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q45
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q46),
q48 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q49 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q47
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q48),
q50 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q51 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q49
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q50),
q52 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e193#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e192#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q53 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q51
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q52),
q54 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q55 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q53
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q54),
q56 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q57 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q55
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q56),
q58 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q59 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q57
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q58),
q60 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q61 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q59
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q60),
q62 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q63 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q61
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q62),
q64 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e192#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q65 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q63
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q64),
q66 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e192#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'city')),
q67 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q65
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q66),
q68 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e192#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'country')),
q69 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q67
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q68),
q70 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e193#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e192#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'continent')),
q71 AS
 (-- UnionAll
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q69
  UNION ALL
  SELECT "friend#3", "_e193#0", "_e192#0" FROM q70),
q72 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'city')),
q73 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'country')),
q74 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q72
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q73),
q75 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'continent')),
q76 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q74
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q75),
q77 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'city')),
q78 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q76
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q77),
q79 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'country')),
q80 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q78
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q79),
q81 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'continent')),
q82 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q80
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q81),
q83 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'city')),
q84 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q82
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q83),
q85 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'country')),
q86 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q84
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q85),
q87 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e192#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e194#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryX#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'continent')),
q88 AS
 (-- UnionAll
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q86
  UNION ALL
  SELECT "_e192#0", "_e194#0", "countryX#0" FROM q87),
q89 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."_e193#0", left_query."_e192#0", right_query."_e194#0", right_query."countryX#0" FROM
    q71 AS left_query
    INNER JOIN
    q88 AS right_query
  ON left_query."_e192#0" = right_query."_e192#0"),
q90 AS
 (-- EquiJoinLike
  SELECT left_query."person#12", left_query."person.id#12", left_query."_e189#0", left_query."friend#3", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", left_query."messageX#0", left_query."_e190#0", left_query."messageX.creationDate#0", left_query."_e191#0", left_query."countryX#0", left_query."countryX.name#0", right_query."_e194#0", right_query."_e193#0", right_query."_e192#0" FROM
    q42 AS left_query
    LEFT OUTER JOIN
    q89 AS right_query
  ON left_query."friend#3" = right_query."friend#3" AND
     left_query."countryX#0" = right_query."countryX#0"),
q91 AS
 (-- Selection
  SELECT * FROM q90 AS subquery
  WHERE ((((NOT(("person#12" = "friend#3")) AND NOT(((((("countryX#0" IS NOT NULL) AND ("_e194#0" IS NOT NULL)) AND ("_e192#0" IS NOT NULL)) AND ("_e193#0" IS NOT NULL)) AND ("friend#3" IS NOT NULL)))) AND ("countryX.name#0" = :countryXName)) AND ("messageX.creationDate#0" >= :startDate)) AND ("messageX.creationDate#0" < :endDate))),
q92 AS
 (-- Grouping
  SELECT "friend#3" AS "friend#3", count(DISTINCT "messageX#0") AS "xCount#0", "friend.id#3" AS "friend.id#3", "friend.firstName#2" AS "friend.firstName#2", "friend.lastName#3" AS "friend.lastName#3"
    FROM q91 AS subquery
  GROUP BY "friend#3", "friend.id#3", "friend.firstName#2", "friend.lastName#3"),
q93 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e195#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#3",
    fromTable."m_creationdate" AS "messageY.creationDate#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NULL)),
q94 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(8, fromTable."m_messageid", fromTable."m_creatorid")::edge_type AS "_e195#0", ROW(0, fromTable."m_creatorid")::vertex_type AS "friend#3",
    fromTable."m_creationdate" AS "messageY.creationDate#0"
    FROM "message" fromTable
  WHERE (fromTable."m_c_replyof" IS NOT NULL)),
q95 AS
 (-- UnionAll
  SELECT "messageY#0", "_e195#0", "friend#3", "messageY.creationDate#0" FROM q93
  UNION ALL
  SELECT "messageY#0", "_e195#0", "friend#3", "messageY.creationDate#0" FROM q94),
q96 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q97 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q98 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q96
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q97),
q99 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q100 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q98
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q99),
q101 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q102 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q100
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q101),
q103 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q104 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q102
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q103),
q105 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "messageY#0", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e196#0", ROW(2, fromTable."m_locationid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q106 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q104
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q105),
q107 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q108 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q106
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q107),
q109 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q110 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q108
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q109),
q111 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q112 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q110
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q111),
q113 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q114 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q112
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q113),
q115 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q116 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q114
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q115),
q117 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "messageY#0", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."o_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q118 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q116
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q117),
q119 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageY#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'city')),
q120 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q118
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q119),
q121 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageY#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'country')),
q122 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q120
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q121),
q123 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "messageY#0", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e196#0", ROW(2, fromTable."p_placeid")::vertex_type AS "countryY#0",
    toTable."pl_name" AS "countryY.name#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'continent')),
q124 AS
 (-- UnionAll
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q122
  UNION ALL
  SELECT "messageY#0", "_e196#0", "countryY#0", "countryY.name#0" FROM q123),
q125 AS
 (-- EquiJoinLike
  SELECT left_query."messageY#0", left_query."_e195#0", left_query."friend#3", left_query."messageY.creationDate#0", right_query."_e196#0", right_query."countryY#0", right_query."countryY.name#0" FROM
    q95 AS left_query
    INNER JOIN
    q124 AS right_query
  ON left_query."messageY#0" = right_query."messageY#0"),
q126 AS
 (-- AllDifferent
  SELECT * FROM q125 AS subquery
    WHERE is_unique(ARRAY[]::edge_type[] || "_e195#0" || "_e196#0")),
q127 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q128 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q129 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q127
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q128),
q130 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q131 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q129
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q130),
q132 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'city')),
q133 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q131
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q132),
q134 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'country')),
q135 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q133
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q134),
q136 AS
 (-- GetEdgesWithGTop
  SELECT ROW(6, fromTable."m_messageid")::vertex_type AS "friend#3", ROW(11, fromTable."m_messageid", fromTable."m_locationid")::edge_type AS "_e198#0", ROW(2, fromTable."m_locationid")::vertex_type AS "_e197#0"
    FROM "message" fromTable
      JOIN "place" toTable ON (fromTable."m_locationid" = toTable."pl_placeid")
  WHERE (fromTable."m_c_replyof" IS NOT NULL) AND
        (toTable."pl_type" :: text ~ 'continent')),
q137 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q135
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q136),
q138 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'city')),
q139 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q137
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q138),
q140 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'country')),
q141 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q139
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q140),
q142 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'university') AND
        (toTable."pl_type" :: text ~ 'continent')),
q143 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q141
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q142),
q144 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'city')),
q145 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q143
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q144),
q146 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'country')),
q147 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q145
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q146),
q148 AS
 (-- GetEdgesWithGTop
  SELECT ROW(1, fromTable."o_organisationid")::vertex_type AS "friend#3", ROW(11, fromTable."o_organisationid", fromTable."o_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."o_placeid")::vertex_type AS "_e197#0"
    FROM "organisation" fromTable
      JOIN "place" toTable ON (fromTable."o_placeid" = toTable."pl_placeid")
  WHERE (fromTable."o_type" :: text ~ 'company') AND
        (toTable."pl_type" :: text ~ 'continent')),
q149 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q147
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q148),
q150 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e197#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'city')),
q151 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q149
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q150),
q152 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e197#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'country')),
q153 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q151
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q152),
q154 AS
 (-- GetEdgesWithGTop
  SELECT ROW(0, fromTable."p_personid")::vertex_type AS "friend#3", ROW(11, fromTable."p_personid", fromTable."p_placeid")::edge_type AS "_e198#0", ROW(2, fromTable."p_placeid")::vertex_type AS "_e197#0"
    FROM "person" fromTable
      JOIN "place" toTable ON (fromTable."p_placeid" = toTable."pl_placeid")
  WHERE (toTable."pl_type" :: text ~ 'continent')),
q155 AS
 (-- UnionAll
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q153
  UNION ALL
  SELECT "friend#3", "_e198#0", "_e197#0" FROM q154),
q156 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'city')),
q157 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'country')),
q158 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q156
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q157),
q159 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'city') AND
        (toTable."pl_type" :: text ~ 'continent')),
q160 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q158
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q159),
q161 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'city')),
q162 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q160
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q161),
q163 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'country')),
q164 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q162
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q163),
q165 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'country') AND
        (toTable."pl_type" :: text ~ 'continent')),
q166 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q164
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q165),
q167 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'city')),
q168 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q166
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q167),
q169 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'country')),
q170 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q168
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q169),
q171 AS
 (-- GetEdgesWithGTop
  SELECT ROW(2, fromTable."pl_placeid")::vertex_type AS "_e197#0", ROW(14, fromTable."pl_placeid", fromTable."pl_containerplaceid")::edge_type AS "_e199#0", ROW(2, fromTable."pl_containerplaceid")::vertex_type AS "countryY#0"
    FROM "place" fromTable
      JOIN "place" toTable ON (fromTable."pl_containerplaceid" = toTable."pl_placeid")
  WHERE (fromTable."pl_type" :: text ~ 'continent') AND
        (toTable."pl_type" :: text ~ 'continent')),
q172 AS
 (-- UnionAll
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q170
  UNION ALL
  SELECT "_e197#0", "_e199#0", "countryY#0" FROM q171),
q173 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."_e198#0", left_query."_e197#0", right_query."_e199#0", right_query."countryY#0" FROM
    q155 AS left_query
    INNER JOIN
    q172 AS right_query
  ON left_query."_e197#0" = right_query."_e197#0"),
q174 AS
 (-- EquiJoinLike
  SELECT left_query."messageY#0", left_query."_e195#0", left_query."friend#3", left_query."messageY.creationDate#0", left_query."_e196#0", left_query."countryY#0", left_query."countryY.name#0", right_query."_e199#0", right_query."_e198#0", right_query."_e197#0" FROM
    q126 AS left_query
    LEFT OUTER JOIN
    q173 AS right_query
  ON left_query."friend#3" = right_query."friend#3" AND
     left_query."countryY#0" = right_query."countryY#0"),
q175 AS
 (-- EquiJoinLike
  SELECT left_query."friend#3", left_query."xCount#0", left_query."friend.id#3", left_query."friend.firstName#2", left_query."friend.lastName#3", right_query."_e198#0", right_query."countryY#0", right_query."countryY.name#0", right_query."messageY.creationDate#0", right_query."_e195#0", right_query."_e196#0", right_query."_e197#0", right_query."messageY#0", right_query."_e199#0" FROM
    q92 AS left_query
    INNER JOIN
    q174 AS right_query
  ON left_query."friend#3" = right_query."friend#3"),
q176 AS
 (-- Selection
  SELECT * FROM q175 AS subquery
  WHERE (((("countryY.name#0" = :countryYName) AND NOT(((((("countryY#0" IS NOT NULL) AND ("_e199#0" IS NOT NULL)) AND ("_e197#0" IS NOT NULL)) AND ("_e198#0" IS NOT NULL)) AND ("friend#3" IS NOT NULL)))) AND ("messageY.creationDate#0" >= :startDate)) AND ("messageY.creationDate#0" < :endDate))),
q177 AS
 (-- Grouping
  SELECT "friend.id#3" AS "personId#1", "friend.firstName#2" AS "personFirstName#1", "friend.lastName#3" AS "personLastName#1", "xCount#0" AS "xCount#0", count(DISTINCT "messageY#0") AS "yCount#0"
    FROM q176 AS subquery
  GROUP BY "friend.id#3", "friend.firstName#2", "friend.lastName#3", "xCount#0"),
q178 AS
 (-- Projection
  SELECT "personId#1" AS "personId#1", "personFirstName#1" AS "personFirstName#1", "personLastName#1" AS "personLastName#1", "xCount#0" AS "xCount#0", "yCount#0" AS "yCount#0", ("xCount#0" + "yCount#0") AS "count#3"
    FROM q177 AS subquery),
q179 AS
 (-- SortAndTop
  SELECT * FROM q178 AS subquery
    ORDER BY "count#3" DESC NULLS LAST, ("personId#1")::BIGINT ASC NULLS FIRST
    LIMIT 20)
SELECT "personId#1" AS "personId", "personFirstName#1" AS "personFirstName", "personLastName#1" AS "personLastName", "xCount#0" AS "xCount", "yCount#0" AS "yCount", "count#3" AS "count"
  FROM q179 AS subquery