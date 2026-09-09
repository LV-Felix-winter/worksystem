-- 锐聘 Q_ITOffer 本地库（兼容本机 MySQL 5.5.22）
-- 连接：127.0.0.1:3306  root / 888

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS q_itoffer DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE q_itoffer;

DROP TABLE IF EXISTS tb_message;
DROP TABLE IF EXISTS tb_favorite;
DROP TABLE IF EXISTS tb_apply;
DROP TABLE IF EXISTS tb_resume;
DROP TABLE IF EXISTS tb_job;
DROP TABLE IF EXISTS tb_company;
DROP TABLE IF EXISTS tb_applicant;
DROP TABLE IF EXISTS tb_users;

CREATE TABLE tb_users (
  user_id INT(11) NOT NULL AUTO_INCREMENT,
  user_logname VARCHAR(50) NOT NULL,
  user_pwd VARCHAR(50) NOT NULL,
  user_realname VARCHAR(60) DEFAULT NULL,
  user_email VARCHAR(100) DEFAULT NULL,
  user_role INT(11) DEFAULT 2 COMMENT '1管理员 2企业用户',
  user_state INT(11) DEFAULT 1 COMMENT '1启用 0禁用',
  PRIMARY KEY (user_id),
  UNIQUE KEY uk_user_logname (user_logname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_company (
  company_id INT(11) NOT NULL AUTO_INCREMENT,
  user_id INT(11) DEFAULT NULL,
  company_name VARCHAR(100) NOT NULL,
  company_area VARCHAR(50) DEFAULT NULL,
  company_size VARCHAR(50) DEFAULT NULL,
  company_type VARCHAR(50) DEFAULT NULL,
  company_brief TEXT,
  company_state INT(11) DEFAULT 1,
  company_sort INT(11) DEFAULT 0,
  company_viewnum INT(11) DEFAULT 0,
  company_pic VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (company_id),
  KEY idx_company_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_job (
  job_id INT(11) NOT NULL AUTO_INCREMENT,
  company_id INT(11) NOT NULL,
  job_name VARCHAR(100) NOT NULL,
  job_hiringnum INT(11) DEFAULT 1,
  job_salary VARCHAR(50) DEFAULT NULL,
  job_area VARCHAR(50) DEFAULT NULL,
  job_desc TEXT,
  job_endtime DATE DEFAULT NULL,
  job_state INT(11) DEFAULT 1 COMMENT '1招聘中 0已下架',
  job_viewnum INT(11) DEFAULT 0,
  PRIMARY KEY (job_id),
  KEY idx_job_company (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_applicant (
  applicant_id INT(11) NOT NULL AUTO_INCREMENT,
  applicant_email VARCHAR(100) NOT NULL,
  applicant_pwd VARCHAR(50) NOT NULL,
  applicant_registdate DATETIME DEFAULT NULL,
  PRIMARY KEY (applicant_id),
  UNIQUE KEY uk_applicant_email (applicant_email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_resume (
  resume_id INT(11) NOT NULL AUTO_INCREMENT,
  applicant_id INT(11) NOT NULL,
  realname VARCHAR(50) DEFAULT NULL,
  gender VARCHAR(10) DEFAULT NULL,
  birthday DATE DEFAULT NULL,
  current_loc VARCHAR(50) DEFAULT NULL,
  resident_loc VARCHAR(50) DEFAULT NULL,
  telephone VARCHAR(30) DEFAULT NULL,
  email VARCHAR(100) DEFAULT NULL,
  job_intension VARCHAR(100) DEFAULT NULL,
  job_experience VARCHAR(500) DEFAULT NULL,
  head_shot VARCHAR(255) DEFAULT NULL,
  attachment VARCHAR(255) DEFAULT NULL,
  completeness INT(11) DEFAULT 0,
  PRIMARY KEY (resume_id),
  KEY idx_resume_applicant (applicant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_apply (
  apply_id INT(11) NOT NULL AUTO_INCREMENT,
  job_id INT(11) NOT NULL,
  resume_id INT(11) NOT NULL,
  apply_date DATETIME DEFAULT NULL,
  apply_state INT(11) DEFAULT 1 COMMENT '1待处理 2已查看 3已面试 0已拒绝',
  PRIMARY KEY (apply_id),
  KEY idx_apply_job (job_id),
  KEY idx_apply_resume (resume_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_role, user_state)
VALUES (1, 'admin', '123456', '系统管理员', 'admin@itoffer.cn', 1, 1);

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_role, user_state)
VALUES (2, 'qingruan', '123456', '青软实训', 'hr@qingruan.cn', 2, 1);

INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
VALUES (1, 2, '青软实训', '青岛', '1000人以上', '教育培训', '面向高校的IT实训与就业服务企业。', 1, 1);

INSERT INTO tb_job (job_id, company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state)
VALUES (1, 1, 'Java Web 开发实习生', 5, '6k-8k', '青岛', '参与锐聘网站开发，使用 JSP / Servlet / JDBC。', '2026-12-31', 1);

INSERT INTO tb_applicant (applicant_id, applicant_email, applicant_pwd, applicant_registdate)
VALUES (1, 'test@itoffer.cn', '123456', NOW());

INSERT INTO tb_resume (resume_id, applicant_id, realname, gender, birthday, current_loc, resident_loc, telephone, email, job_intension, job_experience, completeness)
VALUES (1, 1, '张三', '男', '2004-01-01', '青岛', '济南', '13800000000', 'test@itoffer.cn', 'Java 开发', '熟悉 Servlet、JSP、MySQL。', 80);

CREATE TABLE tb_favorite (
  favorite_id INT(11) NOT NULL AUTO_INCREMENT,
  applicant_id INT(11) NOT NULL,
  job_id INT(11) NOT NULL,
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (favorite_id),
  UNIQUE KEY uk_fav_user_job (applicant_id, job_id),
  KEY idx_fav_job (job_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_message (
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

SET FOREIGN_KEY_CHECKS = 1;
