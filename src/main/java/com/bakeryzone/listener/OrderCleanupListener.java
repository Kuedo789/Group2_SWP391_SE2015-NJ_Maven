package com.bakeryzone.listener;

import com.bakeryzone.dao.OrderDAO;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * Background job tự động chạy mỗi 1 phút.
 * Tìm và hủy các đơn "Chờ thanh toán" (Waiting_Payment) đã quá 15 phút mà
 * khách chưa chuyển khoản.
 * Tomcat tự gọi contextInitialized() khi app khởi động,
 * và contextDestroyed() khi app tắt — không cần Controller nào gọi thủ công.
 */
@WebListener
public class OrderCleanupListener implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        scheduler = Executors.newSingleThreadScheduledExecutor();
        scheduler.scheduleAtFixedRate(() -> {
            try {
                new OrderDAO().cancelExpiredWaitingPaymentOrders();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }, 0, 1, TimeUnit.MINUTES);

        System.out.println("[OrderCleanupListener] Background job đã khởi động: kiểm tra đơn quá hạn mỗi 1 phút.");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdownNow();
        }
        System.out.println("[OrderCleanupListener] Background job đã dừng.");
    }
}
