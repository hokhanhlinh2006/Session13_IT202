CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);
INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');
DELIMITER //
CREATE TRIGGER trg_after_insert_likes
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET like_count = like_count + 1 
    WHERE post_id = NEW.post_id;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER trg_after_delete_likes
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts 
    SET like_count = like_count - 1 
    WHERE post_id = OLD.post_id;
END //
DELIMITER ;
CREATE VIEW user_statistics AS
SELECT 
    u.user_id, 
    u.username, 
    u.post_count, 
    SUM(p.like_count) AS total_likes
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.post_count;
-- Thêm user 2 thích bài viết số 4 (bài của Charlie)
INSERT INTO likes (user_id, post_id, liked_at) VALUES (2, 4, NOW());

-- Kiểm tra xem bài viết số 4 đã tăng like chưa
SELECT post_id, content, like_count FROM posts WHERE post_id = 4;

-- Kiểm tra thống kê tổng quát qua View
SELECT * FROM user_statistics;
-- Giả sử xóa lượt thích vừa thêm (kiểm tra ID trước khi xóa hoặc xóa theo cặp user/post)
DELETE FROM likes WHERE user_id = 2 AND post_id = 4;

-- Kiểm tra lại View để thấy sự thay đổi tự động
SELECT * FROM user_statistics;