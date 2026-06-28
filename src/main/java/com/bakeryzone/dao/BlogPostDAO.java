package com.bakeryzone.dao;

import com.bakeryzone.model.BlogPost;
import com.bakeryzone.utils.DBContext;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class BlogPostDAO {
    private static final Logger LOGGER = Logger.getLogger(BlogPostDAO.class.getName());

    public List<BlogPost> getAllActiveBlogPosts(String categoryFilter) {
        List<BlogPost> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT post_id, title, summary, content, image_url, category, created_at, author_id, status FROM blog_post WHERE status = 'Active'");
        
        boolean hasCategory = categoryFilter != null && !categoryFilter.trim().isEmpty() && !"all".equalsIgnoreCase(categoryFilter.trim());
        if (hasCategory) {
            sql.append(" AND category = ?");
        }
        sql.append(" ORDER BY created_at DESC");

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            if (hasCategory) {
                ps.setString(1, categoryFilter.trim());
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BlogPost p = new BlogPost(
                        rs.getString("post_id"),
                        rs.getString("title"),
                        rs.getString("summary"),
                        rs.getString("content"),
                        rs.getString("image_url"),
                        rs.getString("category"),
                        rs.getTimestamp("created_at"),
                        rs.getString("author_id"),
                        rs.getString("status")
                    );
                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get active blog posts", e);
        }
        return list;
    }

    public BlogPost getBlogPostById(String id) {
        if (id == null || id.trim().isEmpty()) return null;
        String sql = "SELECT post_id, title, summary, content, image_url, category, created_at, author_id, status FROM blog_post WHERE post_id = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new BlogPost(
                        rs.getString("post_id"),
                        rs.getString("title"),
                        rs.getString("summary"),
                        rs.getString("content"),
                        rs.getString("image_url"),
                        rs.getString("category"),
                        rs.getTimestamp("created_at"),
                        rs.getString("author_id"),
                        rs.getString("status")
                    );
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get blog post by ID: " + id, e);
        }
        return null;
    }
}
