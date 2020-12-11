SELECT
  a.Authors,
  p.title.preferred AS Title,
  EXTRACT(YEAR
  FROM
    date_inserted) AS Year,
  COALESCE(p.journal.title,
    p.proceedings_title.preferred,
    p.book_title.preferred,
    p.book_series_title.preferred) AS Source_title,
  p.volume AS Volume,
  p.issue AS Issue,
  CASE
    WHEN REGEXP_CONTAINS(p.pages, r"-") THEN REGEXP_EXTRACT(p.pages, r"^[0-9]+")
  ELSE
  p.pages
END
  AS Page_start,
  CASE
    WHEN REGEXP_CONTAINS(p.pages, r"-") THEN REGEXP_EXTRACT(p.pages, r"(?:-)(.+$)")
  ELSE
  NULL
END
  AS Page_end,
  CASE
    WHEN REGEXP_CONTAINS(p.pages, r"^[0-9]+-[0-9]+$") THEN CAST(CAST(REGEXP_EXTRACT(p.pages, r"[0-9]+$") AS INT64) - CAST(REGEXP_EXTRACT(p.pages, r"^[0-9]+") AS INT64) AS STRING)
  ELSE
  NULL
END
  AS Page_count,
  p.metrics.times_cited AS Cited_by,
  p.doi AS DOI,
  CONCAT("https://app.dimensions.ai/details/publication/", p.id) AS Link,
  /* AS Affiliations,
     AS Authors with affiliations*/
  p.abstract.preferred AS Abstract
  /* Author_Keywords	Index_Keywords	Molecular_Sequence_Numbers	Chemicals_CAS	Tradenames	Manufacturers	Funding_Details	References	Correspondence_Address	Editors	Sponsors	Publisher	Conference name	Conference date	Conference location	Conference code	ISSN	ISBN	CODEN	PubMed ID	Language of Original Document	Abbreviated Source Title	Document Type	Source	EID
*/
FROM
  `covid-19-dimensions-ai.data.publications` p
LEFT JOIN (
  SELECT
    p.id,
    STRING_AGG(CONCAT(author.last_name, ' ', author.first_name), ', ') AS Authors
  FROM
    `covid-19-dimensions-ai.data.publications` p
  CROSS JOIN
    UNNEST(p.authors) AS author
  GROUP BY
    p.id) AS a
ON
  p.id = a.id
ORDER BY
  p.metrics.times_cited DESC
LIMIT
  200;