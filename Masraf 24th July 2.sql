CREATE DATABASE MD24thJ2_db;
USE MD24thJ2_db;

CREATE TABLE users (
	user_id        INT PRIMARY KEY AUTO_INCREMENT,
	username       TEXT,
	email          TEXT,
	password_hash  TEXT,
	full_name      TEXT,
	bio            TEXT,
	is_verified    BOOLEAN
);

SELECT * FROM users ;

INSERT INTO users (username, email, password_hash, full_name, bio, is_verified) VALUES
	('johndoe', 'john@example.com', '$2y$10$examplehash', 'John Doe', 'Digital creator | Photography enthusiast', TRUE),
	('janedoe', 'jane@example.com', '$2y$10$examplehash', 'Jane Smith', 'Travel blogger | Foodie', FALSE),
	('techguy', 'tech@example.com', '$2y$10$examplehash', 'Mike Johnson', 'Tech enthusiast | Gadget reviewer', TRUE),
	('foodlover', 'food@example.com', '$2y$10$examplehash', 'Sarah Williams', 'Sharing my culinary adventures', FALSE),
	('travelbug', 'travel@example.com', '$2y$10$examplehash', 'Alex Chen', 'Wanderlust | Adventure seeker', FALSE);

CREATE TABLE posts (
	post_id    INT PRIMARY KEY AUTO_INCREMENT,
	user_id    INT,
	caption    TEXT,
	image_url  TEXT,
	location   TEXT,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM posts ;

INSERT INTO posts (user_id, caption, image_url, location) VALUES
	(1, 'Beautiful sunset at the beach today! #sunset #beach', 'sunset.jpg', 'Malibu Beach'),
	(2, 'My new favorite restaurant in town! #foodie', 'restaurant.jpg', 'Downtown Bistro'),
	(3, 'Just unboxed the latest smartphone - review coming soon! #tech', 'phone.jpg', NULL),
	(4, 'Homemade pasta for dinner tonight #homecooking', 'pasta.jpg', 'My Kitchen'),
	(5, 'Exploring the mountains this weekend #adventure', 'mountains.jpg', 'Rocky Mountains');

CREATE TABLE comments (
	comment_id  INT PRIMARY KEY AUTO_INCREMENT,
	post_id     INT,
	user_id     INT,
	content     TEXT,
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

SELECT * FROM comments ;

INSERT INTO comments (post_id, user_id, content) VALUES
	(1, 2, 'Wow, this looks amazing!'),
	(1, 3, 'Great shot!'),
	(2, 1, 'What dish would you recommend?'),
	(3, 5, 'Looking forward to your review!'),
	(4, 2, 'Recipe please!');

CREATE TABLE likes (
	like_id  INT PRIMARY KEY AUTO_INCREMENT,
	post_id  INT,
	user_id  INT,
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (post_id) REFERENCES posts(post_id)
);

SELECT * FROM likes ;

INSERT INTO likes (post_id, user_id) VALUES
	(1, 2), 
	(1, 3), 
	(1, 4), 
	(2, 1), 
	(3, 5), 
	(4, 2), 
	(5, 1);

CREATE TABLE follows (
	follow_id     INT PRIMARY KEY AUTO_INCREMENT,
	follower_id   INT,
	following_id  INT,
	FOREIGN KEY (follower_id) REFERENCES users(user_id),
	FOREIGN KEY (following_id) REFERENCES users(user_id)
);

SELECT * FROM follows ;

INSERT INTO follows (follower_id, following_id) VALUES
	(2, 1), 
	(3, 1), 
	(4, 1), 
	(1, 2), 
	(5, 2), 
	(1, 3),
	(4, 3);

CREATE TABLE messages (
	message_id   INT PRIMARY KEY AUTO_INCREMENT,
	sender_id    INT,
	receiver_id  INT,
	content      TEXT,
	FOREIGN KEY (sender_id) REFERENCES users(user_id),
	FOREIGN KEY (receiver_id) REFERENCES users(user_id)
);

SELECT * FROM messages ;

INSERT INTO messages (sender_id, receiver_id, content) VALUES
	(1, 2, 'Hey Jane, how are you?'),
	(2, 1, 'Hi John! I''m good, thanks!'),
	(3, 1, 'Would you like to collaborate on a project?');

CREATE TABLE stories (
	storie_id   INT PRIMARY KEY AUTO_INCREMENT,
	user_id     INT,
	media_url   TEXT,
	expires_at  DATETIME,
	FOREIGN KEY (user_id) REFERENCES users(user_id)
);

SELECT * FROM stories ;

INSERT INTO stories (user_id, media_url, expires_at) VALUES
	(1, 'story1.jpg', DATE_ADD(NOW(), INTERVAL 24 HOUR)),
	(2, 'story2.jpg', DATE_ADD(NOW(), INTERVAL 24 HOUR)),
	(5, 'story3.jpg', DATE_ADD(NOW(), INTERVAL 24 HOUR));
	
CREATE TABLE hashtags (
	hashtag_id  INT PRIMARY KEY AUTO_INCREMENT,
	tag         TEXT
);

SELECT * FROM hashtags ;

INSERT INTO hashtags (tag) VALUES
	('#sunset'), 
	('#beach'), 
	('#foodie'), 
	('#tech'), 
	('#homecooking'), 
	('#adventure');

CREATE TABLE post_Hashtags (
	post_Hashtag_id  INT PRIMARY KEY AUTO_INCREMENT,
	post_id          INT,
	hashtag_id       INT,
	FOREIGN KEY (post_id) REFERENCES posts(post_id),
	FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id)
);

SELECT * FROM post_Hashtags ;

INSERT INTO post_Hashtags (post_id, hashtag_id) VALUES
	(1, 1), 
	(1, 2), 
	(2, 3),
	(3, 4), 
	(4, 5), 
	(5, 6);

CREATE TABLE notifications (
	notification_id  INT PRIMARY KEY AUTO_INCREMENT,
	user_id          INT,
	actor_id         INT,
	type             TEXT,
	post_id          INT,
	comment_id       INT,
	FOREIGN KEY (user_id) REFERENCES users(user_id),
	FOREIGN KEY (actor_id) REFERENCES users(user_id),
	FOREIGN KEY (post_id) REFERENCES posts(post_id),
	FOREIGN KEY (comment_id) REFERENCES comments(comment_id)
);

SELECT * FROM notifications ;

INSERT INTO notifications (user_id, actor_id, type, post_id, comment_id) VALUES
	(1, 2, 'like', 1, NULL),
	(1, 3, 'comment', 1, 2),
	(2, 1, 'comment', 2, 3),
	(1, 2, 'follow', NULL, NULL);

-- 2. Show the top 5 most active users based on their combined count of posts, comments, and likes given.
SELECT 
    u.username,u.full_name,
    COALESCE(p.post_count, 0) AS post_count,
    COALESCE(c.comment_count, 0) AS comment_count,
    COALESCE(l.like_count, 0) AS like_count,
    COALESCE(p.post_count, 0) + COALESCE(c.comment_count, 0) + COALESCE(l.like_count, 0) AS activity_score
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS post_count
    FROM posts
    GROUP BY user_id
) p ON u.user_id = p.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY user_id
) c ON u.user_id = c.user_id
LEFT JOIN (
    SELECT user_id, COUNT(*) AS like_count
    FROM likes
    GROUP BY user_id
) l ON u.user_id = l.user_id
ORDER BY activity_score DESC
LIMIT 5;

-- 3. Identify posts with more than 10 likes but fewer than 3 comments.
SELECT 
    u.username,p.caption,
    COALESCE(l.like_count, 0) AS total_likes,
    COALESCE(c.comment_count, 0) AS total_comments
FROM posts p
JOIN users u ON u.user_id=p.user_id
LEFT JOIN (
    SELECT post_id, COUNT(*) AS like_count
    FROM likes
    GROUP BY post_id
) l ON p.post_id = l.post_id
LEFT JOIN (
    SELECT post_id, COUNT(*) AS comment_count
    FROM comments
    GROUP BY post_id
) c ON p.post_id = c.post_id
WHERE 
	COALESCE(l.like_count, 0) > 10
    AND COALESCE(c.comment_count, 0) < 3;
  
-- 4. Find all hashtags that have been used in at least 5 different posts, ordered by popularity.
SELECT 
    h.tag,
    COUNT(DISTINCT ph.post_id) AS post_count
FROM hashtags h
JOIN post_Hashtags ph ON h.hashtag_id = ph.hashtag_id
GROUP BY h.hashtag_id, h.tag
HAVING COUNT(DISTINCT ph.post_id) >= 5
ORDER BY post_count DESC;

-- 5. Calculate the average number of comments per post for each user, including those with zero comments.
SELECT 
    u.username,u.full_name,
    COALESCE(post_stats.total_posts, 0) AS total_posts,
    COALESCE(comment_stats.total_comments, 0) AS total_comments,
    CASE 
        WHEN COALESCE(post_stats.total_posts, 0) = 0 THEN 0
        ELSE ROUND(comment_stats.total_comments / post_stats.total_posts, 2)
    END AS avg_comments_per_post
FROM users u
LEFT JOIN (
    SELECT user_id, COUNT(*) AS total_posts
    FROM posts
    GROUP BY user_id
) post_stats ON u.user_id = post_stats.user_id
LEFT JOIN (
    SELECT p.user_id, COUNT(c.comment_id) AS total_comments
    FROM posts p
    LEFT JOIN comments c ON p.post_id = c.post_id
    GROUP BY p.user_id
) comment_stats ON u.user_id = comment_stats.user_id;

-- 6. Show the percentage of followers who have liked at least one post from the accounts they follow.
SELECT 
    u.username,
    COALESCE(fstats.total_followers, 0) AS total_followers,
    COALESCE(engaged_stats.engaged_followers, 0) AS engaged_followers,
    ROUND(
        100.0 * COALESCE(engaged_stats.engaged_followers, 0) / NULLIF(fstats.total_followers, 0),
        2
    ) AS engagement_rate
FROM users u
LEFT JOIN (
    SELECT following_id AS user_id, COUNT(*) AS total_followers
    FROM follows
    GROUP BY following_id
) fstats ON u.user_id = fstats.user_id
LEFT JOIN (
    SELECT 
        fl.following_id AS user_id,
        COUNT(DISTINCT fl.follower_id) AS engaged_followers
    FROM follows fl
    JOIN posts p ON p.user_id = fl.following_id
    JOIN likes l ON l.post_id = p.post_id AND l.user_id = fl.follower_id
    GROUP BY fl.following_id
) engaged_stats ON u.user_id = engaged_stats.user_id
ORDER BY engagement_rate DESC;

-- 7. Find all pairs of users who follow each other (mutual follows).
SELECT 
    u1.username AS user1,
    u2.username AS user2
FROM follows f1
JOIN follows f2 
    ON f1.follower_id = f2.following_id 
    AND f1.following_id = f2.follower_id
JOIN users u1 ON f1.follower_id = u1.user_id
JOIN users u2 ON f1.following_id = u2.user_id
WHERE f1.follower_id < f1.following_id;

-- 8. Identify potential influencer accounts (users who have at least 100 followers but follow fewer than 20 accounts).
SELECT 
    u.username,u.full_name,
    COALESCE(followers.count_followers, 0) AS followers_count,
    COALESCE(following.count_following, 0) AS following_count
FROM users u
LEFT JOIN (
    SELECT following_id AS user_id, COUNT(*) AS count_followers
    FROM follows
    GROUP BY following_id
) followers ON u.user_id = followers.user_id
LEFT JOIN (
    SELECT follower_id AS user_id, COUNT(*) AS count_following
    FROM follows
    GROUP BY follower_id
) following ON u.user_id = following.user_id
WHERE COALESCE(followers.count_followers, 0) >= 100
  AND COALESCE(following.count_following, 0) < 20;
