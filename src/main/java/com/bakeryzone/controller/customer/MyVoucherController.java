package com.bakeryzone.controller.customer;

import com.bakeryzone.dao.VoucherDAO;
import com.bakeryzone.model.User;
import com.bakeryzone.model.Voucher;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@WebServlet(name = "MyVoucherController", urlPatterns = {"/my-vouchers"})
public class MyVoucherController extends HttpServlet {

    private final VoucherDAO voucherDAO = new VoucherDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            List<Voucher> voucherList = voucherDAO.getUserOwnedVouchers(user.getUserId());
            request.setAttribute("voucherList", voucherList);
            request.getRequestDispatcher("/customer/my-vouchers.jsp").forward(request, response);
        } catch (Exception ex) {
            ex.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải kho voucher");
        }
    }
}
