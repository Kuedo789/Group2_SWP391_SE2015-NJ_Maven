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
        
        int page = 1;
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        
        int pageSize = 5; // Default to 5 items per page for units
        
        List<UnitMeasure> list = unitMeasureDAO.getAllUnitMeasures();
        
        // Let's filter the list based on search term
        if (!search.trim().isEmpty()) {
            final String finalSearch = search.trim().toLowerCase();
            list = list.stream()
                .filter(u -> (u.getUnitId() != null && u.getUnitId().toLowerCase().contains(finalSearch)) 
                          || (u.getUnitName() != null && u.getUnitName().toLowerCase().contains(finalSearch)))
                .collect(java.util.stream.Collectors.toList());
        }

        int totalCount = list.size();
        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) {
            totalPages = 1;
        }
        if (page > totalPages) {
            page = totalPages;
        }
        
        int fromIndex = (page - 1) * pageSize;
        int toIndex = Math.min(fromIndex + pageSize, totalCount);
        List<UnitMeasure> paginatedList = list.subList(fromIndex, toIndex);

        request.setAttribute("unitList", paginatedList);
        request.setAttribute("search", search);
        request.setAttribute("currentPage", page);
        request.setAttribute("pageSize", pageSize);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
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
        boolean nameValid = unitName != null && !unitName.isEmpty() && unitName.length() >= 2 && unitName.length() <= 50;
        boolean descValid = description == null || description.length() <= 255;

        if (!idValid || !nameValid || !descValid) {
            UnitMeasure unit = new UnitMeasure(unitId, unitName, description);
            request.setAttribute("unit", unit);
            if (!idValid) {
                request.setAttribute("error", "Dữ liệu nhập vào không hợp lệ. Mã đơn vị tối đa 10 ký tự và không được để trống.");
            } else if (!nameValid) {
                request.setAttribute("error", "Dữ liệu nhập vào không hợp lệ. Tên đơn vị phải từ 2 đến 50 ký tự.");
            } else {
                request.setAttribute("error", "Dữ liệu nhập vào không hợp lệ. Mô tả chi tiết tối đa 255 ký tự.");
            }
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
