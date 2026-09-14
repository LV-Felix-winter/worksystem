-- 锐聘 Q_ITOffer 本地库（兼容本机 MySQL 5.5.22）
-- 连接：127.0.0.1:3306  root / 888

SET NAMES utf8;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS q_itoffer DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE q_itoffer;

DROP TABLE IF EXISTS tb_talk_msg;
DROP TABLE IF EXISTS tb_talk;
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
  user_phone VARCHAR(20) DEFAULT NULL,
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
  job_area VARCHAR(80) DEFAULT NULL,
  job_desc TEXT,
  job_endtime DATE DEFAULT NULL,
  job_state INT(11) DEFAULT 1 COMMENT '1招聘中 0已下架',
  job_viewnum INT(11) DEFAULT 0,
  job_cover VARCHAR(255) DEFAULT NULL,
  job_thumb VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (job_id),
  KEY idx_job_company (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_applicant (
  applicant_id INT(11) NOT NULL AUTO_INCREMENT,
  applicant_email VARCHAR(100) NOT NULL,
  applicant_pwd VARCHAR(50) NOT NULL,
  applicant_name VARCHAR(50) DEFAULT NULL,
  applicant_phone VARCHAR(20) DEFAULT NULL,
  applicant_registdate DATETIME DEFAULT NULL,
  PRIMARY KEY (applicant_id),
  UNIQUE KEY uk_applicant_email (applicant_email),
  UNIQUE KEY uk_applicant_phone (applicant_phone)
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
  education TEXT,
  project_exp TEXT,
  work_exp TEXT,
  skills TEXT,
  honors TEXT,
  self_eval TEXT,
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

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
VALUES (1, 'admin', '123456', '系统管理员', 'admin@itoffer.cn', NULL, 1, 1);

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
VALUES (2, 'qingruan', '123456', '青软实训', 'hr@qingruan.cn', '13900139000', 2, 1);

INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
VALUES (1, 2, '青软实训', '青岛', '1000人以上', '教育培训', '面向高校的IT实训与就业服务企业。', 1, 1);

INSERT INTO tb_job (job_id, company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_cover, job_thumb)
VALUES (1, 1, 'Java Web 开发实习生', 5, '6k-8k', '青岛', '参与锐聘网站开发，使用 JSP / Servlet / JDBC。', '2026-12-31', 1, '/images/banner-1.jpg', '/images/job-thumb-1.jpg');

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
VALUES (3, 'lingzhi', '123456', '凌志软件', 'hr@lingzhi.cn', '13700137000', 2, 1);
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
VALUES (4, 'trans', '123456', '大宇宙信息', 'hr@trans.cn', '13600136000', 2, 1);

INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
VALUES (2, 3, '凌志软件', '苏州市', '100人以上', '股份制企业', '国家重点规划布局内企业，全国二百强之一。国内软件出口全国第八名。通过 CMMI5 级认证。服务日本最大的证券公司。', 1, 2);
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
VALUES (3, 4, '苏州大宇宙信息创造有限公司', '苏州市', '500人以上', '外商独资', '是全球服务外包百强第44位。企业 transcosmos 株式会社100%控股。2012年集团位居中国 BPO TOP20 第3位。', 1, 3);

INSERT INTO tb_job (job_id, company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_cover, job_thumb)
VALUES (2, 2, 'Java 软件开发', 8, '2500~4000元/月', '吴中区', '参与对日软件开发，熟悉 Java 与数据库。', '2026-12-31', 1, '/images/banner-2.jpg', '/images/job-thumb-4.jpg');
INSERT INTO tb_job (job_id, company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_cover, job_thumb)
VALUES (3, 3, '前端开发工程师', 6, '2500~4000元/月', '工业园区', '负责 Web 前端开发与交互实现。', '2026-12-31', 1, '/images/banner-3.jpg', '/images/job-thumb-3.jpg');
INSERT INTO tb_job (job_id, company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_cover, job_thumb)
VALUES (4, 1, '软件测试实习生', 4, '5k-7k', '青岛', '参与功能测试与缺陷跟踪。', '2026-12-31', 1, '/images/banner-4.jpg', '/images/job-thumb-2.jpg');

INSERT INTO tb_applicant (applicant_id, applicant_email, applicant_pwd, applicant_name, applicant_phone, applicant_registdate)
VALUES (1, 'test@itoffer.cn', '123456', '张三', '13800138000', NOW());

INSERT INTO tb_resume (resume_id, applicant_id, realname, gender, birthday, current_loc, resident_loc, telephone, email, job_intension, job_experience, completeness, head_shot)
VALUES (1, 1, '张三', '男', '2004-01-01', '青岛', '济南', '13800000000', 'test@itoffer.cn', 'Java 开发', '熟悉 Servlet、JSP、MySQL。', 80, '/images/avatar-1.svg');

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

CREATE TABLE tb_talk (
  talk_id INT(11) NOT NULL AUTO_INCREMENT,
  job_id INT(11) NOT NULL,
  company_id INT(11) NOT NULL,
  applicant_id INT(11) NOT NULL,
  last_time DATETIME DEFAULT NULL,
  PRIMARY KEY (talk_id),
  UNIQUE KEY uk_talk_job_app (job_id, applicant_id),
  KEY idx_talk_company (company_id),
  KEY idx_talk_applicant (applicant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE tb_talk_msg (
  msg_id INT(11) NOT NULL AUTO_INCREMENT,
  talk_id INT(11) NOT NULL,
  sender_type VARCHAR(20) NOT NULL COMMENT 'applicant / company',
  content VARCHAR(1000) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (msg_id),
  KEY idx_talk_msg (talk_id, msg_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tb_applicant (applicant_id, applicant_email, applicant_pwd, applicant_name, applicant_phone, applicant_registdate) VALUES
(2, 'lisiqi@itoffer.cn', '123456', '李思琪', '13800138001', NOW()),
(3, 'wanghaoran@itoffer.cn', '123456', '王浩然', '13800138002', NOW()),
(4, 'chenyuan@itoffer.cn', '123456', '陈予安', '13800138003', NOW()),
(5, 'zhaoqiming@itoffer.cn', '123456', '赵启明', '13800138004', NOW());

INSERT INTO tb_resume (applicant_id, realname, gender, birthday, current_loc, resident_loc, telephone, email, job_intension, job_experience, education, head_shot, completeness) VALUES
(2, '李思琪', '女', '2003-05-18', '杭州', '温州', '13800138001', 'lisiqi@itoffer.cn', '前端开发', '做过校园官网改版，熟悉 Vue 与切图还原。', '浙江大学||计算机科学与技术||硕士||2024.09-2027.06||||前端工程、人机交互', '/images/avatar-2.svg', 76),
(3, '王浩然', '男', '2002-08-09', '青岛', '潍坊', '13800138002', 'wanghaoran@itoffer.cn', '软件测试', '能写用例、跟缺陷，熟悉接口联调。', '中国海洋大学||软件工程||本科||2020.09-2024.06||GPA 3.5/4||软件测试、数据库原理', '/images/avatar-3.svg', 76),
(4, '陈予安', '女', '2004-03-22', '济南', '临沂', '13800138003', 'chenyuan@itoffer.cn', '产品助理', '做过课程项目需求梳理和原型。', '山东大学||数字媒体技术||本科||2022.09-2026.06||||交互设计、产品思维', '/images/avatar-4.svg', 76),
(5, '赵启明', '男', '2000-11-02', '北京', '石家庄', '13800138004', 'zhaoqiming@itoffer.cn', 'Java 开发', '有分布式课设经验，能独立完成接口。', '北京邮电大学||软件工程||硕士||2023.09-2026.06||||分布式系统、Java 后端', '/images/avatar-5.svg', 76);

INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state)
SELECT 1, resume_id, DATE_SUB(NOW(), INTERVAL 3 DAY), 1 FROM tb_resume WHERE applicant_id = 2;
INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state)
SELECT 4, resume_id, DATE_SUB(NOW(), INTERVAL 8 DAY), 2 FROM tb_resume WHERE applicant_id = 3;
INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state)
SELECT 1, resume_id, DATE_SUB(NOW(), INTERVAL 1 DAY), 3 FROM tb_resume WHERE applicant_id = 4;
INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state)
SELECT 4, resume_id, DATE_SUB(NOW(), INTERVAL 5 DAY), 1 FROM tb_resume WHERE applicant_id = 5;

SET FOREIGN_KEY_CHECKS = 1;
