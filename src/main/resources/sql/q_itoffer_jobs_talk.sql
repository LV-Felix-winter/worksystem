-- 补充多省市/工种职位 + 双方沟通表（可重复执行）
SET NAMES utf8;
USE q_itoffer;

ALTER TABLE tb_job MODIFY job_area VARCHAR(80) DEFAULT NULL;

CREATE TABLE IF NOT EXISTS tb_talk (
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

CREATE TABLE IF NOT EXISTS tb_talk_msg (
  msg_id INT(11) NOT NULL AUTO_INCREMENT,
  talk_id INT(11) NOT NULL,
  sender_type VARCHAR(20) NOT NULL COMMENT 'applicant / company',
  content VARCHAR(1000) DEFAULT NULL,
  create_time DATETIME DEFAULT NULL,
  PRIMARY KEY (msg_id),
  KEY idx_talk_msg (talk_id, msg_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

UPDATE tb_job SET job_desc = '【岗位方向】Java Web 开发实习，参与锐聘招聘站点迭代。\n【工作地点】山东省 / 青岛市 / 崂山区（可接受驻场实训）。\n【岗位职责】\n1. 使用 JSP / Servlet / JDBC 完成职位检索、投递、后台分页等功能模块；\n2. 按接口约定编写动态 SQL，处理关键词、地区、薪资区间过滤；\n3. 联调前台页面与会话登录，修复常见空指针与编码问题；\n4. 编写简要开发记录，配合测试同学回归缺陷。\n【任职要求】\n1. 计算机相关专业在校生或应届生，每周可出勤 4 天以上；\n2. 掌握 Java SE、HTML/CSS，了解 HTTP 与 MVC；\n3. 会 MySQL 基本查询，能看懂表结构和外键关系；\n4. 沟通主动，能接受 Code Review。\n【加分项】用过 Tomcat 部署、Git、Ajax 或写过课程设计。\n【薪资与培养】6k-8k，含 8 周岗前培训，表现优秀可留用转正。'
WHERE job_id = 1 AND (job_desc IS NULL OR CHAR_LENGTH(job_desc) < 80);

UPDATE tb_job SET job_desc = '【岗位方向】对日 Java 软件开发，服务证券行业客户。\n【工作地点】江苏省 / 苏州市 / 吴中区。\n【岗位职责】\n1. 按日方设计书实现业务功能，完成编码、单测与缺陷修改；\n2. 参与详细设计评审，输出处理流程图与接口说明；\n3. 维护既有对日批次与账务模块，保障月末结算窗口稳定；\n4. 与桥接翻译、测试、运维协同发布。\n【任职要求】\n1. 熟悉 Java、SQL，了解 Spring 或 SSH 其一即可；\n2. 能阅读日文设计书或愿意接受公司日语强化；\n3. 细心、能适应坐班与阶段性加班。\n【加分项】N2 及以上、CMMI 项目经历、证券或银行系统经验。\n【薪资】2500~4000 元/月（实习/校招生），转正后按职级调整。'
WHERE job_id = 2 AND (job_desc IS NULL OR CHAR_LENGTH(job_desc) < 80);

UPDATE tb_job SET job_desc = '【岗位方向】Web 前端开发，面向客服与运营后台。\n【工作地点】江苏省 / 苏州市 / 工业园区。\n【岗位职责】\n1. 还原设计稿，实现列表、表单、弹层与响应式布局；\n2. 用原生 JS / jQuery 完成后端接口联调，处理分页与校验；\n3. 优化首屏与表格渲染，兼容 Chrome / Edge；\n4. 沉淀公共样式，减少重复代码。\n【任职要求】\n1. 熟练 HTML/CSS/JS，理解盒模型与 Flex；\n2. 了解 Ajax、JSON、跨域基本概念；\n3. 有作品集或课程项目可演示。\n【加分项】Vue、ECharts、无障碍与组件化经验。'
WHERE job_id = 3 AND (job_desc IS NULL OR CHAR_LENGTH(job_desc) < 80);

UPDATE tb_job SET job_desc = '【岗位方向】功能测试实习，覆盖招聘业务主路径。\n【工作地点】山东省 / 青岛市 / 市南区。\n【岗位职责】\n1. 根据需求编写测试用例，覆盖登录、检索、投递、收藏；\n2. 执行冒烟与回归，记录缺陷（步骤、期望、实际、截图）；\n3. 协助接口字段核对与兼容性抽测；\n4. 输出周报与质量小结。\n【任职要求】\n1. 细心、逻辑清晰，会写清晰的复现步骤；\n2. 了解软件测试流程，会基本 SQL 查询；\n3. 能接受缺陷跟踪工具（禅道/Jira 其一即可）。\n【加分项】写过接口用例、了解抓包或自动化入门。'
WHERE job_id = 4 AND (job_desc IS NULL OR CHAR_LENGTH(job_desc) < 80);

INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 5, 'yunqi', '123456', '成都云栖科技', 'hr@yunqi.cn', '13500135001', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 5 OR user_logname = 'yunqi');
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 6, 'qinghe', '123456', '杭州青荷电商', 'hr@qinghe.cn', '13500135002', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 6 OR user_logname = 'qinghe');
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 7, 'xinglan', '123456', '深圳星澜网络', 'hr@xinglan.cn', '13500135003', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 7 OR user_logname = 'xinglan');
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 8, 'beichen', '123456', '北京北辰数据', 'hr@beichen.cn', '13500135004', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 8 OR user_logname = 'beichen');
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 9, 'lingbo', '123456', '西安凌波软件', 'hr@lingbo.cn', '13500135005', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 9 OR user_logname = 'lingbo');
INSERT INTO tb_users (user_id, user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state)
SELECT 10, 'jiangxia', '123456', '武汉江夏云', 'hr@jiangxia.cn', '13500135006', 2, 1 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_users WHERE user_id = 10 OR user_logname = 'jiangxia');

INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 4, 5, '成都云栖科技', '四川省 / 成都市 / 高新区', '200-500人', '民营企业',
       '面向西部产业互联网的产品与算法团队，做供应链协同与智能推荐。办公在天府软件园，双休，提供导师制。', 1, 4 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 4 OR company_name = '成都云栖科技');
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 5, 6, '杭州青荷电商', '浙江省 / 杭州市 / 余杭区', '500-1000人', '民营企业',
       '新零售与直播电商服务商，自研商家后台与投放工具，节奏快，强调数据复盘。', 1, 5 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 5 OR company_name = '杭州青荷电商');
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 6, 7, '深圳星澜网络', '广东省 / 深圳市 / 南山区', '100-300人', '合资企业',
       '移动应用与安全合规服务，客户覆盖支付、出行。办公室在科技园，强调工程规范。', 1, 6 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 6 OR company_name = '深圳星澜网络');
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 7, 8, '北京北辰数据', '北京市 / 市辖区 / 海淀区', '100-200人', '股份制企业',
       '企业数据中台与增长分析，服务零售与教育客户。中关村办公，研究空气较浓。', 1, 7 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 7 OR company_name = '北京北辰数据');
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 8, 9, '西安凌波软件', '陕西省 / 西安市 / 雁塔区', '300-500人', '民营企业',
       '工业软件与嵌入式交付，服务装备制造客户。提供岗前硬件入门课。', 1, 8 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 8 OR company_name = '西安凌波软件');
INSERT INTO tb_company (company_id, user_id, company_name, company_area, company_size, company_type, company_brief, company_state, company_sort)
SELECT 9, 10, '武汉江夏云计算', '湖北省 / 武汉市 / 洪山区', '200-400人', '民营企业',
       '政务云与中小企业上云服务，自研监控与发布平台，光谷办公。', 1, 9 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM tb_company WHERE company_id = 9 OR company_name = '武汉江夏云计算');

INSERT INTO tb_job (company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_viewnum)
SELECT t.company_id, t.job_name, t.hire, t.salary, t.area, t.desc_text, '2026-12-31', 1, t.vnum
FROM (
  SELECT 4 AS company_id, 'B 端产品经理' AS job_name, 2 AS hire, '12k-18k' AS salary,
         '四川省 / 成都市 / 高新区' AS area, 41 AS vnum,
         '【岗位方向】产业互联网 B 端产品，负责商家协同工作台。\n【工作地点】四川省 / 成都市 / 高新区（天府软件园）。\n【岗位职责】\n1. 访谈商家运营与仓配同事，整理需求池并排期；\n2. 输出 PRD、原型与验收标准，跟进研发与测试；\n3. 设计订单、对账、异常工单等核心流程，减少人工对账；\n4. 复盘转化与工时，推动下一迭代。\n【任职要求】\n1. 1 年以上 B 端或电商后台产品经验，会 Axure / Figma 其一；\n2. 能把业务语言翻译成字段、状态机和权限；\n3. 逻辑清楚，会写验收用例。\n【加分项】供应链、WMS、财务对账经验；会基本 SQL。' AS desc_text
  UNION ALL
  SELECT 4, '机器学习工程师', 2, '16k-24k', '四川省 / 成都市 / 高新区', 36,
         '【岗位方向】推荐与需求预测，服务订货与选品。\n【工作地点】四川省 / 成都市 / 高新区。\n【岗位职责】\n1. 基于历史订单做特征与样本，训练召回/排序或时序预测模型；\n2. 将模型接到 Java 服务，监控离线指标与线上效果；\n3. 与产品和业务对齐评估口径，避免只看离线 AUC；\n4. 沉淀特征字典与复现实验。\n【任职要求】\n1. 熟悉 Python、SQL，了解 sklearn / PyTorch 其一；\n2. 理解过拟合、样本偏差、特征穿越；\n3. 能独立完成从取数到评估的闭环。\n【加分项】推荐、预测、NLP 项目或论文；了解特征平台。'
  UNION ALL
  SELECT 5, '电商运营专员', 4, '7k-11k', '浙江省 / 杭州市 / 余杭区', 29,
         '【岗位方向】店铺与直播间日常运营。\n【工作地点】浙江省 / 杭州市 / 余杭区（靠近未来科技城）。\n【岗位职责】\n1. 制定周活动节奏：券、赠品、直播场次与复盘；\n2. 盯转化、客单、退货，定位详情页与客服话术问题；\n3. 对接设计出主图/短视频脚本，跟进上架时效；\n4. 维护商家后台商品与库存，避免超卖。\n【任职要求】\n1. 有淘宝/抖音/拼多多任一平台实操；\n2. 会看基础报表，Excel 熟练；\n3. 抗压，能接受大促值班。\n【加分项】会投放、会剪辑、有达人合作经验。'
  UNION ALL
  SELECT 5, 'Vue 前端工程师', 3, '13k-20k', '浙江省 / 杭州市 / 余杭区', 44,
         '【岗位方向】商家后台与投放工作台前端。\n【工作地点】浙江省 / 杭州市 / 余杭区。\n【岗位职责】\n1. 用 Vue 3 + 组件库实现表格、筛选、图表与权限路由；\n2. 封装上传、导出、长列表，保证大促活动页稳定；\n3. 与后端约定分页与错误码，处理弱网与重复提交；\n4. 参与设计走查，补齐空态和加载态。\n【任职要求】\n1. 熟练 Vue、ES6、CSS，理解组件通信与状态；\n2. 了解 REST、鉴权、跨域；\n3. 有完整后台项目可演示。\n【加分项】Vite、Pinia、ECharts、性能排查经验。'
  UNION ALL
  SELECT 6, 'Android 开发工程师', 3, '14k-22k', '广东省 / 深圳市 / 南山区', 38,
         '【岗位方向】出行/支付类 App 业务迭代。\n【工作地点】广东省 / 深圳市 / 南山区（科技园）。\n【岗位职责】\n1. 用 Kotlin/Java 完成页面、网络层与本地缓存；\n2. 处理权限、推送、深链与兼容机型；\n3. 配合安全同事做加固、证书锁定与日志脱敏；\n4. 跟进崩溃与 ANR，输出周报。\n【任职要求】\n1. 熟悉 Android SDK、生命周期、RecyclerView；\n2. 了解 OKHttp/Retrofit、MMKV 或同类方案；\n3. 能独立定位线上问题。\n【加分项】Jetpack、Compose、音视频或支付合规经验。'
  UNION ALL
  SELECT 6, '网络安全工程师', 2, '15k-23k', '广东省 / 深圳市 / 南山区', 22,
         '【岗位方向】应用安全与等保合规支撑。\n【工作地点】广东省 / 深圳市 / 南山区。\n【岗位职责】\n1. 对 Web/App 做漏洞扫描与手工验证，输出修复建议；\n2. 跟进 XSS、越权、弱口令、敏感信息泄露等常见问题；\n3. 协助等保测评材料、日志留存与应急演练；\n4. 给研发做安全编码培训。\n【任职要求】\n1. 熟悉 OWASP Top 10，会 Burp / 抓包；\n2. 了解 Linux、防火墙与 HTTPS 证书；\n3. 能写清楚的漏洞报告。\n【加分项】有 SRC 积分、等保/ISO 项目、脚本化扫描。'
  UNION ALL
  SELECT 7, '数据分析师', 3, '12k-19k', '北京市 / 市辖区 / 海淀区', 51,
         '【岗位方向】增长与留存分析，服务零售客户看板。\n【工作地点】北京市 / 市辖区 / 海淀区（中关村）。\n【岗位职责】\n1. 搭建漏斗、队列、渠道对比，周会解读异常；\n2. 用 SQL 取数，用 Excel/Python 出图，沉淀指标口径；\n3. 配合产品做 A/B 实验设计与显著性判断；\n4. 输出月度经营简报。\n【任职要求】\n1. 熟练 SQL（多表、窗口函数入门即可）；\n2. 理解转化、留存、LTV 等基本概念；\n3. 表达清楚，能把数字讲成建议。\n【加分项】统计学课程、Tableau/PowerBI、增长实验经验。'
  UNION ALL
  SELECT 7, '用户增长产品经理', 1, '14k-21k', '北京市 / 市辖区 / 朝阳区', 27,
         '【岗位方向】获客与激活，负责活动页与邀请链路。\n【工作地点】北京市 / 市辖区 / 朝阳区（可接受海淀协作）。\n【岗位职责】\n1. 规划拉新活动、邀请奖励与落地页，对齐投放素材；\n2. 拆解新增、激活、次日留，定位流失节点；\n3. 与数据、设计、研发共创实验，小步验证；\n4. 控制补贴成本，避免刷量。\n【任职要求】\n1. 有增长、运营或 C 端产品经验；\n2. 会看渠道报表，理解归因；\n3. 结果导向，能接受失败实验。\n【加分项】投放、私域、裂变玩法落地经验。'
  UNION ALL
  SELECT 8, '嵌入式软件工程师', 3, '11k-17k', '陕西省 / 西安市 / 雁塔区', 18,
         '【岗位方向】工控采集与通信固件。\n【工作地点】陕西省 / 西安市 / 雁塔区。\n【岗位职责】\n1. 基于 STM32/RTOS 完成采集、报警与串口/CAN 通信；\n2. 编写驱动与协议解析，对接上位机；\n3. 参与硬件联调、温测与现场问题定位；\n4. 维护版本与发布说明。\n【任职要求】\n1. 熟悉 C，了解中断、DMA、定时器；\n2. 能看原理图与数据手册；\n3. 细心，接受出差到客户现场。\n【加分项】FreeRTOS、Modbus、Linux 应用层。'
  UNION ALL
  SELECT 8, 'Java 对日开发工程师', 4, '9k-14k', '陕西省 / 西安市 / 雁塔区', 25,
         '【岗位方向】对日业务系统维护与增强。\n【工作地点】陕西省 / 西安市 / 雁塔区。\n【岗位职责】\n1. 按日文票实现功能与缺陷修复；\n2. 编写单测与发布检查清单；\n3. 参加早会，同步进度与风险；\n4. 协助新人熟悉模块。\n【任职要求】\n1. 熟悉 Java、SQL，了解 Spring；\n2. 能借助词典阅读日文票；\n3. 守时、文档习惯好。\n【加分项】N3 及以上、金融或制造领域经验。'
  UNION ALL
  SELECT 9, '云计算运维工程师', 2, '10k-16k', '湖北省 / 武汉市 / 洪山区', 33,
         '【岗位方向】政务云主机与发布平台运维。\n【工作地点】湖北省 / 武汉市 / 洪山区（光谷）。\n【岗位职责】\n1. 负责 Linux 主机、Nginx、MySQL 日常巡检与备份；\n2. 配合发布窗口做回滚预案与监控告警；\n3. 处理磁盘、连接数、慢查询等常见故障；\n4. 编写运维手册，值守节假日轮班。\n【任职要求】\n1. 熟悉 Linux 常用命令与 shell；\n2. 了解网络、防火墙、证书；\n3. 有责任心，故障时能同步进展。\n【加分项】Docker、Prometheus、云厂商认证。'
  UNION ALL
  SELECT 9, '接口测试工程师', 3, '8k-13k', '湖北省 / 武汉市 / 洪山区', 21,
         '【岗位方向】云平台 OpenAPI 测试。\n【工作地点】湖北省 / 武汉市 / 洪山区。\n【岗位职责】\n1. 根据接口文档编写用例，覆盖鉴权、幂等、边界值；\n2. 用 Postman / JMeter 做功能与轻量压测；\n3. 核对库表与日志，定位参数与状态码问题；\n4. 推动研发补文档与错误码。\n【任职要求】\n1. 了解 HTTP、JSON、Token；\n2. 会 SQL，能对比请求与落库；\n3. 缺陷描述完整。\n【加分项】Python 脚本、CI 集成、契约测试。'
  UNION ALL
  SELECT 2, '软件实施顾问', 2, '8k-12k', '江苏省 / 苏州市 / 虎丘区', 16,
         '【岗位方向】对日项目驻场实施与客户沟通。\n【工作地点】江苏省 / 苏州市 / 虎丘区，阶段性驻客户现场。\n【岗位职责】\n1. 收集现场需求，整理成开发票与验收清单；\n2. 组织培训、导数据、协助上线；\n3. 跟踪缺陷关闭，写周报给双方项目经理；\n4. 维护客户关系，发现续约机会。\n【任职要求】\n1. 沟通清楚，能接受出差；\n2. 了解软件交付流程；\n3. 会基础 SQL 与 Excel。\n【加分项】日语、证券或制造客户经验。'
  UNION ALL
  SELECT 3, '日语客服专员', 6, '6k-9k', '江苏省 / 苏州市 / 工业园区', 19,
         '【岗位方向】BPO 在线客服，服务日资客户热线/邮件。\n【工作地点】江苏省 / 苏州市 / 工业园区（轮班）。\n【岗位职责】\n1. 按话术处理咨询、投诉与工单升级；\n2. 记录客户问题，同步给质检与业务；\n3. 参与话术优化与新人带教；\n4. 完成服务质量抽检整改。\n【任职要求】\n1. 日语口语达到日常沟通（N3 及以上优先）；\n2. 打字快，态度稳；\n3. 能接受轮班。\n【加分项】客服、电商、呼叫中心经验。'
  UNION ALL
  SELECT 1, 'UI 视觉设计师', 2, '8k-13k', '山东省 / 青岛市 / 崂山区', 14,
         '【岗位方向】招聘站点与企业后台视觉。\n【工作地点】山东省 / 青岛市 / 崂山区。\n【岗位职责】\n1. 输出 Banner、职位卡、简历页与后台组件规范；\n2. 与前端对齐切图、间距、状态色；\n3. 参与可用性走查，补空态与错误态；\n4. 维护绿色主题色板与图标库。\n【任职要求】\n1. 熟练 Figma / PS，有 Web 作品集；\n2. 理解栅格、对比度与可读性；\n3. 能接受改稿。\n【加分项】动效、插画、设计系统经验。'
) t
WHERE EXISTS (SELECT 1 FROM tb_company c WHERE c.company_id = t.company_id)
  AND NOT EXISTS (SELECT 1 FROM tb_job j WHERE j.company_id = t.company_id AND j.job_name = t.job_name);

INSERT INTO tb_talk (job_id, company_id, applicant_id, last_time)
SELECT 1, 1, 1, NOW() FROM DUAL
WHERE EXISTS (SELECT 1 FROM tb_job WHERE job_id = 1)
  AND EXISTS (SELECT 1 FROM tb_applicant WHERE applicant_id = 1)
  AND NOT EXISTS (SELECT 1 FROM tb_talk WHERE job_id = 1 AND applicant_id = 1);

INSERT INTO tb_talk_msg (talk_id, sender_type, content, create_time)
SELECT t.talk_id, x.sender_type, x.content, DATE_ADD(NOW(), INTERVAL x.mins MINUTE)
FROM tb_talk t
JOIN (
  SELECT 'company' AS sender_type, '您好，我是青软实训招聘同事。看到您在看「Java Web 开发实习生」，方便聊聊近期课程项目和每周可出勤天数吗？' AS content, -40 AS mins
  UNION ALL
  SELECT 'applicant', '您好，我是在校生，做过 JSP/Servlet 的课程设计，每周可以到岗 4 天，想了解岗前培训怎么安排。', -25
  UNION ALL
  SELECT 'company', '培训一共 8 周：前 3 周补 Servlet/JDBC，后 5 周进真实项目组。表现好可以留用。您方便发一份简历或作品截图吗？', -10
) x
WHERE t.job_id = 1 AND t.applicant_id = 1
  AND NOT EXISTS (SELECT 1 FROM tb_talk_msg m WHERE m.talk_id = t.talk_id);
