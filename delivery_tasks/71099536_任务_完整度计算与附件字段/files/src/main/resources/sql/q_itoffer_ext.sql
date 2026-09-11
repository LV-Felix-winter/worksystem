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

-- ===== #71099528/#71099529 演示数据（佟乐，可重复执行） =====
-- 多条件检索 + 热门排序需要足够样本：补 3 条职位（含不同地区/薪资/浏览量/下架态）
INSERT INTO tb_job (company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_viewnum)
SELECT t.company_id, t.job_name, t.hire, t.salary, t.area, t.desc_text, t.end_time, t.state, t.vnum
FROM (
    SELECT 1 AS company_id, 'Java 后端工程师' AS job_name, 3 AS hire, '12k-18k' AS salary, '济南' AS area,
           '负责锐聘后端接口开发，Servlet/JDBC/MySQL，要求熟悉事务与分页。' AS desc_text,
           '2026-11-30' AS end_time, 1 AS state, 58 AS vnum
    UNION ALL
    SELECT 1, '前端工程师', 2, '8k-14k', '青岛', '负责锐聘前台页面，JSP/HTML/CSS/JS，会 ECharts 优先。', '2026-10-31', 1, 32
    UNION ALL
    SELECT 1, '测试实习生', 5, '4k-6k', '青岛', '参与页面功能与接口测试，编写测试用例。', '2026-09-30', 0, 12
) t
WHERE NOT EXISTS (
    SELECT 1 FROM tb_job j WHERE j.company_id = t.company_id AND j.job_name = t.job_name AND j.job_area = t.area
)
  AND EXISTS (SELECT 1 FROM tb_company c WHERE c.company_id = t.company_id);

-- 投递状态流转演示：张三已投 2 条，状态分别为「已查看」「已拒绝」
INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state)
SELECT t.job_id, 1, NOW(), t.state FROM (
    SELECT 2 AS job_id, 2 AS state
    UNION ALL
    SELECT 3, 0
) t
JOIN tb_job j ON j.job_id = t.job_id
WHERE NOT EXISTS (SELECT 1 FROM tb_apply a WHERE a.job_id = t.job_id AND a.resume_id = 1);

-- 收藏演示：张三收藏了 1 条职位
INSERT INTO tb_favorite (applicant_id, job_id, create_time)
SELECT 1, 1, NOW()
WHERE NOT EXISTS (SELECT 1 FROM tb_favorite WHERE applicant_id = 1 AND job_id = 1);

-- 站内消息演示：企业更新状态后给求职者的提醒
INSERT INTO tb_message (receiver_type, receiver_id, title, content, is_read, create_time)
SELECT 'applicant', 1, '投递状态更新', '企业对「Java 后端工程师」的投递状态更新为：已查看。', 0, NOW()
WHERE NOT EXISTS (SELECT 1 FROM tb_message WHERE receiver_type = 'applicant' AND receiver_id = 1 AND title = '投递状态更新');
