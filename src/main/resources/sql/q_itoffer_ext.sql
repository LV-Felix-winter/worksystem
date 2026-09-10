-- 锐聘差异化扩展（可重复执行，不删已有数据）
-- SQLyog：选中 q_itoffer 后整份运行；或：mysql -uroot -p888 --default-character-set=utf8 < q_itoffer_ext.sql

SET NAMES utf8;
USE q_itoffer;

CREATE TABLE IF NOT EXISTS tb_favorite (
  favorite_id INT(11) NOT NULL AUTO_INCREMENT,
  applicant_id INT(11) NOT NULL,
  job_id INT(11) NOT NULL,
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (favorite_id),
  UNIQUE KEY uk_fav_user_job (applicant_id, job_id),
  KEY idx_fav_job (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS tb_message (
  message_id INT(11) NOT NULL AUTO_INCREMENT,
  receiver_type VARCHAR(20) NOT NULL COMMENT 'applicant / user',
  receiver_id INT(11) NOT NULL,
  title VARCHAR(100) DEFAULT NULL,
  content VARCHAR(500) DEFAULT NULL,
  is_read INT(11) DEFAULT 0 COMMENT '0未读 1已读',
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (message_id),
  KEY idx_msg_receiver (receiver_type, receiver_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP PROCEDURE IF EXISTS sp_qitoffer_add_column;
DELIMITER $$
CREATE PROCEDURE sp_qitoffer_add_column(
  IN p_table VARCHAR(64),
  IN p_column VARCHAR(64),
  IN p_def VARCHAR(255)
)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table
      AND COLUMN_NAME = p_column
  ) THEN
    SET @ddl = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_column, '` ', p_def);
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END$$
DELIMITER ;

CALL sp_qitoffer_add_column('tb_resume', 'attachment', 'VARCHAR(255) DEFAULT NULL');
CALL sp_qitoffer_add_column('tb_resume', 'completeness', 'INT(11) DEFAULT 0');
CALL sp_qitoffer_add_column('tb_job', 'job_viewnum', 'INT(11) DEFAULT 0');
CALL sp_qitoffer_add_column('tb_applicant', 'applicant_name', 'VARCHAR(50) DEFAULT NULL');
CALL sp_qitoffer_add_column('tb_applicant', 'applicant_phone', 'VARCHAR(20) DEFAULT NULL');
CALL sp_qitoffer_add_column('tb_users', 'user_phone', 'VARCHAR(20) DEFAULT NULL');

DROP PROCEDURE IF EXISTS sp_qitoffer_add_column;

UPDATE tb_resume SET completeness = 80 WHERE resume_id = 1 AND (completeness IS NULL OR completeness = 0);
UPDATE tb_applicant SET applicant_name = '张三', applicant_phone = '13800138000' WHERE applicant_id = 1;
UPDATE tb_users SET user_phone = '13900139000' WHERE user_id = 2 AND user_logname = 'qingruan';
