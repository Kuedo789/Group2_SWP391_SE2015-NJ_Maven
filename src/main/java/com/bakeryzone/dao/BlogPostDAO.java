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
        StringBuilder sql = new StringBuilder(
                "SELECT post_id, title, summary, content, image_url, category, created_at, author_id, status FROM blog_post WHERE status = 'Active'");

        boolean hasCategory = categoryFilter != null && !categoryFilter.trim().isEmpty()
                && !"all".equalsIgnoreCase(categoryFilter.trim());
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
                            rs.getString("status"));
                    list.add(p);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get active blog posts", e);
        }
        return list;
    }

    public BlogPost getBlogPostById(String id) {
        if (id == null || id.trim().isEmpty())
            return null;
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
                            rs.getString("status"));
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get blog post by ID: " + id, e);
        }
        return null;
    }

    public boolean insertBlogPost(BlogPost post) {
        String sql = "INSERT INTO blog_post (post_id, title, summary, content, image_url, category, created_at, author_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, post.getPostId());
            ps.setString(2, post.getTitle());
            ps.setString(3, post.getSummary());
            ps.setString(4, post.getContent());
            ps.setString(5, post.getImageUrl());
            ps.setString(6, post.getCategory());
            ps.setTimestamp(7, post.getCreatedAt() != null ? post.getCreatedAt() : new java.sql.Timestamp(System.currentTimeMillis()));
            ps.setString(8, post.getAuthorId());
            ps.setString(9, post.getStatus() != null ? post.getStatus() : "Active");
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to insert blog post", e);
        }
        return false;
    }

    public boolean updateBlogPost(BlogPost post) {
        String sql = "UPDATE blog_post SET title = ?, summary = ?, content = ?, image_url = ?, category = ?, status = ? WHERE post_id = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, post.getTitle());
            ps.setString(2, post.getSummary());
            ps.setString(3, post.getContent());
            ps.setString(4, post.getImageUrl());
            ps.setString(5, post.getCategory());
            ps.setString(6, post.getStatus());
            ps.setString(7, post.getPostId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to update blog post: " + post.getPostId(), e);
        }
        return false;
    }

    public boolean deleteBlogPost(String id) {
        String sql = "UPDATE blog_post SET status = 'Deleted' WHERE post_id = ?";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to soft delete blog post: " + id, e);
        }
        return false;
    }

    public List<BlogPost> getBlogPostsPagedAdmin(String keyword, String category, String status, String sort, int pageIndex, int pageSize) {
        List<BlogPost> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT post_id, title, summary, content, image_url, category, created_at, author_id, status FROM blog_post WHERE status <> 'Deleted'");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR summary LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category.trim())) {
            sql.append(" AND category = ?");
            params.add(category.trim());
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        String orderBy = " ORDER BY created_at DESC ";
        if (sort != null && !sort.trim().isEmpty()) {
            switch (sort.trim().toLowerCase()) {
                case "date_asc":
                    orderBy = " ORDER BY created_at ASC ";
                    break;
                case "title_asc":
                    orderBy = " ORDER BY title ASC ";
                    break;
                case "title_desc":
                    orderBy = " ORDER BY title DESC ";
                    break;
                default:
                    orderBy = " ORDER BY created_at DESC ";
                    break;
            }
        }
        sql.append(orderBy).append("LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((pageIndex - 1) * pageSize);

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
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
            LOGGER.log(Level.SEVERE, "Failed to get blog posts for admin", e);
        }
        return list;
    }

    public int getTotalBlogPostsCountAdmin(String keyword, String category, String status) {
        int count = 0;
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM blog_post WHERE status <> 'Deleted'");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR summary LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        if (category != null && !category.trim().isEmpty() && !"all".equalsIgnoreCase(category.trim())) {
            sql.append(" AND category = ?");
            params.add(category.trim());
        }

        if (status != null && !status.trim().isEmpty() && !"all".equalsIgnoreCase(status.trim())) {
            sql.append(" AND status = ?");
            params.add(status.trim());
        }

        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to count blog posts for admin", e);
        }
        return count;
    }

    public List<String> getAllCategories() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT DISTINCT category FROM blog_post WHERE category IS NOT NULL AND category <> ''";
        try (Connection conn = DBContext.getJDBCConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(rs.getString("category"));
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to get all categories", e);
        }
        return list;
    }
}
