DELIMITER //
CREATE TRIGGER tg_CheckSelfLike
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE owner_id INT;
    
    -- Lấy user_id của chủ bài viết
    SELECT user_id INTO owner_id FROM posts WHERE post_id = NEW.post_id;
    
    -- Kiểm tra nếu người like chính là chủ bài viết
    IF NEW.user_id = owner_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bạn không thể thích bài viết của chính mình!';
    END IF;
END //
DELIMITER ;
-- Khi thêm Like
DELIMITER //
CREATE TRIGGER tg_UpdateLikeCountInsert
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END //

-- Khi xóa Like
CREATE TRIGGER tg_UpdateLikeCountDelete
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER tg_UpdateLikeCountUpdate
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    -- Giảm like của bài viết cũ
    UPDATE posts SET like_count = like_count - 1 WHERE post_id = OLD.post_id;
    -- Tăng like của bài viết mới
    UPDATE posts SET like_count = like_count + 1 WHERE post_id = NEW.post_id;
END //
DELIMITER ;
-- Lệnh này sẽ vấp phải Trigger tg_CheckSelfLike và báo lỗi
INSERT INTO likes (user_id, post_id) VALUES (1, 1);
-- Bob (id=2) like bài của Alice (id=1, post_id=1)
INSERT INTO likes (user_id, post_id) VALUES (2, 1);

-- Kiểm tra
SELECT post_id, like_count FROM posts WHERE post_id = 1;
-- Giả sử bản ghi like đó có like_id = 5 (bạn hãy kiểm tra ID thực tế của bạn)
UPDATE likes SET post_id = 3 WHERE user_id = 2 AND post_id = 1;

-- Kiểm tra: Bài 1 phải giảm 1 like, bài 3 phải tăng 1 like
SELECT post_id, like_count FROM posts WHERE post_id IN (1, 3);
SELECT * FROM user_statistics;	