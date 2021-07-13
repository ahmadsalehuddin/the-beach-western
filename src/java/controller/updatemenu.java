package controller;

import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

public class updatemenu extends HttpServlet {

    private static final long serialVersionUID = 102831973239L;
    private PreparedStatement updateStmt;

    @Override
    public void init() throws ServletException {
        initializeJdbc();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String menuImagePath = null;
        boolean menuAvailability = false;
        List<String> completeSet = new ArrayList<String>();

        if (ServletFileUpload.isMultipartContent(request)) {
            try {
                List<FileItem> multiparts = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
                for (FileItem item : multiparts) {
                    if (!item.isFormField()) {
                        ServletContext servletContext = getServletContext();
                        String contextPath = servletContext.getRealPath(File.separator);
                        menuImagePath = new File(item.getName()).getName();
                        item.write(new File(contextPath + "../../web/assets/menu-image/" + File.separator + menuImagePath));
                    } else {
                        completeSet.add(item.getString());
                    }
                }
                //File uploaded successfully
                request.setAttribute("message", "File Uploaded Successfully");

            } catch (Exception ex) {
                request.setAttribute("message", "File Upload Failed due to " + ex);
            }
        } else {
            request.setAttribute("message", "No File found");
        }
        
        if(menuImagePath == null || menuImagePath.trim().length() == 0) {
            menuImagePath = completeSet.get(1);
        }
        
        if(completeSet.get(4).equals("True")) {
            menuAvailability = true;
        }

        try {
            updateStmt.setString(1, completeSet.get(2));
            updateStmt.setDouble(2, Double.parseDouble(completeSet.get(3)));
            updateStmt.setBoolean(3, menuAvailability);
            updateStmt.setString(4, menuImagePath);
            updateStmt.setInt(5, Integer.parseInt(completeSet.get(0)));
            updateStmt.executeUpdate();
        } catch (SQLException ex) {

        }

        request.setAttribute("updateStatus", "success");
        request.getRequestDispatcher("/updatemenu.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    private void initializeJdbc() {
        try {
            String driver = "org.apache.derby.jdbc.ClientDriver";
            String connectionString = "jdbc:derby://localhost:1527/thebeachwestern;create=true;user=app;password=app";

            Class.forName(driver);

            Connection conn = DriverManager.getConnection(connectionString);

            updateStmt = conn.prepareStatement("UPDATE MENU SET MENUNAME = ?, "
                    + "MENUPRICE = ?, ISAVAILABLE = ?, URLIMAGE = ? "
                    + "WHERE MENUID = ?");
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
