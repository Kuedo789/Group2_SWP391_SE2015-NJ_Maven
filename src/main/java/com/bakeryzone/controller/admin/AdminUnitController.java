package com.bakeryzone.controller.admin;

import com.bakeryzone.dao.UnitMeasureDAO;
import com.bakeryzone.model.UnitMeasure;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/unit")
public class AdminUnitController extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private final UnitMeasureDAO unitMeasureDAO = new UnitMeasureDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "list":
                handleList(request, response);
                break;
            case "create":
                showCreateForm(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            default:
                handleList(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        switch (action) {
            case "create":
                createUnit(request, response);
                break;
            case "update":
                updateUnit(request, response);
                break;
            case "delete":
                deleteUnit(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/unit?action=list");
                break;
        }
    }

    private void handleList(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String search = request.getParameter("search");
        if (search == null) {
            search = "";
        }
        
        List<UnitMeasure> list = unitMeasureDAO.getAllUnitMeasures();
        
        // Let's filter the list based on search term
        if (!search.trim().isEmpty()) {
            final String finalSearch = search.trim().toLowerCase();
            list = list.stream()
                .filter(u -> (u.getUnitId() != null && u.getUnitId().toLowerCase().contains(finalSearch)) 
                          || (u.getUnitName() != null && u.getUnitName().toLowerCase().contains(finalSearch)))
                .collect(java.util.stream.Collectors.toList());
        }

        request.setAttribute("unitList", list);
        request.setAttribute("search", search);
        request.getRequestDispatcher("/admin/unitList.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        UnitMeasure unit = new UnitMeasure();
        request.setAttribute("unit", unit);
        request.setAttribute("formAction", "create");
        request.setAttribute("isEdit", false);
        request.getRequestDispatcher("/admin/unitDetail.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        UnitMeasure unit = unitMeasureDAO.getUnitMeasureById(id);
        
        if (unit == null) {
            response.sendRedirect(request.getContextPath() + "/admin/unit?action=list");
            return;
        }

        request.setAttribute("unit", unit);
        request.setAttribute("formAction", "update");
        request.setAttribute("isEdit", true);
        request.getRequestDispatcher("/admin/unitDetail.jsp").forward(request, response);
    }

    private void createUnit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateUnit(request, response, true);
    }

    private void updateUnit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        saveOrUpdateUnit(request, response, false);
    }

    private void deleteUnit(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String id = request.getParameter("id");
        String searchParam = request.getParameter("search");
        
        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/unit?action=list");
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        }

        if (id != null && !id.trim().isEmpty()) {
            boolean success = unitMeasureDAO.deleteUnitMeasure(id);
            if (success) {
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_success");
            } else {
                response.sendRedirect(redirectUrl.toString() + "&msg=delete_error");
            }
        } else {
            response.sendRedirect(redirectUrl.toString());
        }
    }

    private void saveOrUpdateUnit(HttpServletRequest request, HttpServletResponse response, boolean isNew) 
            throws ServletException, IOException {
        String unitId = request.getParameter("unitId");
        String unitName = request.getParameter("unitName");
        String description = request.getParameter("description");
        String searchParam = request.getParameter("search");

        if (unitId != null) unitId = unitId.trim().toUpperCase();
        if (unitName != null) unitName = unitName.trim();
        if (description != null) description = description.trim();

        boolean idValid = unitId != null && !unitId.isEmpty() && unitId.length() <= 10;
        boolean nameValid = unitName != null && !unitName.isEmpty() && unitName.length() >= 2;

        if (!idValid || !nameValid) {
            UnitMeasure unit = new UnitMeasure(unitId, unitName, description);
            request.setAttribute("unit", unit);
            request.setAttribute("error", "Dữ liệu nhập vào không hợp lệ. Mã đơn vị tối đa 10 ký tự, Tên đơn vị tối thiểu 2 ký tự.");
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.setAttribute("isEdit", !isNew);
            request.getRequestDispatcher("/admin/unitDetail.jsp").forward(request, response);
            return;
        }

        // Check ID uniqueness on creation
        if (isNew) {
            UnitMeasure existing = unitMeasureDAO.getUnitMeasureById(unitId);
            if (existing != null) {
                UnitMeasure unit = new UnitMeasure(unitId, unitName, description);
                request.setAttribute("unit", unit);
                request.setAttribute("error", "Mã đơn vị tính này đã tồn tại trong hệ thống.");
                request.setAttribute("formAction", "create");
                request.setAttribute("isEdit", false);
                request.getRequestDispatcher("/admin/unitDetail.jsp").forward(request, response);
                return;
            }
        }

        UnitMeasure unit = new UnitMeasure(unitId, unitName, description);
        boolean success = unitMeasureDAO.saveUnitMeasure(unit);

        StringBuilder redirectUrl = new StringBuilder(request.getContextPath() + "/admin/unit?action=list");
        if (searchParam != null && !searchParam.trim().isEmpty()) {
            redirectUrl.append("&search=").append(java.net.URLEncoder.encode(searchParam, "UTF-8"));
        }

        if (success) {
            response.sendRedirect(redirectUrl.toString() + "&msg=" + (isNew ? "add_success" : "edit_success"));
        } else {
            request.setAttribute("unit", unit);
            request.setAttribute("error", "Lỗi hệ thống khi lưu đơn vị tính.");
            request.setAttribute("formAction", isNew ? "create" : "update");
            request.setAttribute("isEdit", !isNew);
            request.getRequestDispatcher("/admin/unitDetail.jsp").forward(request, response);
        }
    }
}
