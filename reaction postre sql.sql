-- Step 1: Define positive and negative sentiments
WITH sentiment_classification AS (
    SELECT reactiontype,
           CASE
               WHEN reactiontype IN ('love', 'adore', 'cherish', 'heart', 'super love', 'like', 'interested', 'intrigued') THEN 'positive'
               WHEN reactiontype IN ('hate', 'dislike', 'disgust', 'scared', 'worried', 'indifferent', 'peeking') THEN 'negative'
               ELSE 'neutral'
           END AS sentiment
    FROM public.reactiontable
    GROUP BY reactiontype
),

-- Step 2: Select top categories
top_categories AS (
    SELECT category
    FROM public.reactiontable
    GROUP BY category
    ORDER BY COUNT(*) DESC
    LIMIT 5
),

-- Step 3: Sum up reaction counts by category and sentiment
category_sentiments AS (
    SELECT rt.category,
           sc.sentiment,
           COUNT(*) AS reaction_count
    FROM public.reactiontable rt
    JOIN sentiment_classification sc ON rt.reactiontype = sc.reactiontype
    WHERE rt.category IN (SELECT category FROM top_categories)
    GROUP BY rt.category, sc.sentiment
),

-- Step 4: Calculate positive sentiment score for each category
category_positive_sentiments AS (
    SELECT category,
           SUM(CASE WHEN sentiment = 'positive' THEN reaction_count ELSE 0 END) AS positive_count,
           SUM(CASE WHEN sentiment = 'negative' THEN reaction_count ELSE 0 END) AS negative_count
    FROM category_sentiments
    GROUP BY category
)

-- Step 5: Select the category with the highest positive sentiment
SELECT category, positive_count, negative_count
FROM category_positive_sentiments
ORDER BY positive_count DESC
LIMIT 5;

WITH top_categories AS (
    SELECT category
    FROM public.reactiontable
    GROUP BY category
    ORDER BY COUNT(*) DESC
    LIMIT 5
)
SELECT rt.category, rt.reactiontype, COUNT(*) as reaction_count
FROM public.reactiontable rt
WHERE rt.category IN (SELECT category FROM top_categories)
GROUP BY rt.category, rt.reactiontype
ORDER BY rt.category, reaction_count DESC;

SELECT category, COUNT(*) as reaction_count
FROM public.reactiontable
GROUP BY category
ORDER BY reaction_count DESC
LIMIT 5;

-- Extract the month from the post_date and count the number of posts per month
SELECT 
    TO_CHAR(dates, 'monthname') AS month,
    COUNT(*) AS post_count
FROM 
    public.reactiontable
GROUP BY 
    month
ORDER BY 
    post_count DESC
LIMIT 5;
