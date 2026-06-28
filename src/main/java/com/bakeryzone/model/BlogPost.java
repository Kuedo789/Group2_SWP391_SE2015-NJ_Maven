package com.bakeryzone.model;

import java.sql.Timestamp;

public class BlogPost {
    private String postId;
    private String title;
    private String summary;
    private String content;
    private String imageUrl;
    private String category;
    private Timestamp createdAt;
    private String authorId;
    private String status;

    public BlogPost() {
    }

    public BlogPost(String postId, String title, String summary, String content, String imageUrl, String category, Timestamp createdAt, String authorId, String status) {
        this.postId = postId;
        this.title = title;
        this.summary = summary;
        this.content = content;
        this.imageUrl = imageUrl;
        this.category = category;
        this.createdAt = createdAt;
        this.authorId = authorId;
        this.status = status;
    }

    public String getPostId() {
        return postId;
    }

    public void setPostId(String postId) {
        this.postId = postId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getSummary() {
        return summary;
    }

    public void setSummary(String summary) {
        this.summary = summary;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAuthorId() {
        return authorId;
    }

    public void setAuthorId(String authorId) {
        this.authorId = authorId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
