package com.qitoffer.entity;

import java.util.Date;

public class TalkMsg {
    private int msgId;
    private int talkId;
    private String senderType;
    private String content;
    private Date createTime;

    public int getMsgId() { return msgId; }
    public void setMsgId(int msgId) { this.msgId = msgId; }
    public int getTalkId() { return talkId; }
    public void setTalkId(int talkId) { this.talkId = talkId; }
    public String getSenderType() { return senderType; }
    public void setSenderType(String senderType) { this.senderType = senderType; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
}
