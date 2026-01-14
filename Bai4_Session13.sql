CREATE TABLE post_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by_user_id INT,
    CONSTRAINT fk_history_post FOREIGN KEY (post_id) 
        REFERENCES posts(post_id) ON DELETE CASCADE
);
DELIMITER //

CREATE TRIGGER tg_SavePostHistory
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    -- Chỉ ghi lại lịch sử nếu nội dung thực sự bị thay đổi
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id, 
            old_content, 
            new_content, 
            changed_at, 
            changed_by_user_id
        )
        VALUES (
            OLD.post_id, 
            OLD.content, 
            NEW.content, 
            NOW(), 
            OLD.user_id -- Giả định người sửa là chủ bài viết
        );
    END IF;
END //

DELIMITER ;
UPDATE posts 
SET content = 'Nội dung này đã được Alice chỉnh sửa lần 1' 
WHERE post_id = 1;

UPDATE posts 
SET content = 'Alice cập nhật nội dung lần 2' 
WHERE post_id = 1;
SELECT * FROM post_history WHERE post_id = 1;
-- Kiểm tra lượt thích hiện tại của bài 1
SELECT post_id, content, like_count FROM posts WHERE post_id = 1;

-- Thêm một like mới để xem trigger cũ (bài trước) còn chạy không
INSERT INTO likes (user_id, post_id) VALUES (3, 1);

-- Kiểm tra lại: like_count phải tăng, và content phải giữ đúng bản mới nhất
SELECT post_id, content, like_count FROM posts WHERE post_id = 1;