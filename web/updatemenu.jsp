<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<sql:setDataSource var="beachData" url="jdbc:derby://localhost:1527/thebeachwestern"
                   driver="org.apache.derby.jdbc.ClientDriver"
                   user="app" password="app"/>

<sql:transaction dataSource="${beachData}">
    <c:if test="${param.deleteMenu == 'true' && param.menuID != null}">
        <sql:update var="deleteResult">
            DELETE FROM MENU WHERE MENUID = ?
            <sql:param value="${param.menuID}"/>
        </sql:update>
        <c:if test="${deleteResult > 0}">
            <c:set var="deleteStatus" value="success"/>
        </c:if>
    </c:if>

    <sql:query var="menuQuery">
        SELECT * FROM MENU
    </sql:query>
</sql:transaction>


<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <link href="css/style.css" rel="stylesheet">
        <title>The Beach Western and Chinese Food Muslim &mdash; Update Menu</title>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-light bg-light p-2">
            <div class="container">
                <a class="navbar-brand" href="#">
                    <img src="assets/logo/thebeachwestern.jpg" alt="" width="30" height="30" class="d-inline-block align-text-top">&emsp;
                    The Beach Western and Chinese Food Muslim
                </a>
            </div>
        </nav>

        <div class="container">
            <h2 class="mt-4">Update Menu</h2>


            <c:if test="${updateStatus == 'success'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <strong>Hooray!</strong> A menu has been successfully updated.
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <c:if test="${deleteStatus == 'success'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    A menu has been deleted successfully!
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <table class="table table-hover">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Menu Name</th>
                        <th scope="col">Price</th>
                        <th scope="col">Availability</th>
                        <th scope="col">Image</th>
                        <th scope="col">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:set var="numRow" value="1"/>
                    <c:forEach var="rowMenu" items="${menuQuery.rows}">
                        <tr>
                            <th scope="row">${numRow}</th>
                    <form id="updateForm${rowMenu.MENUID}" method="post" action="updatemenu" enctype="multipart/form-data">
                        <input type="hidden" name="menuID" value="${rowMenu.MENUID}">
                        <input type="hidden" name="menuImagePath" value="${rowMenu.URLIMAGE}">
                        <td>
                            <input type="text" name="menuName" class="form-control" value="${rowMenu.MENUNAME}" required>
                        </td>
                        <td>
                            <div class="input-group">
                                <div class="input-group-prepend">
                                    <span class="input-group-text">RM</span>
                                </div>
                                <input type="number" name="menuPrice" class="form-control" value="<fmt:formatNumber type="number" minFractionDigits="2" maxFractionDigits="2" value="${rowMenu.MENUPRICE}"/>" step=".01" required>
                            </div>
                        </td>
                        <td>
                            <select name="menuAvailability" class="form-control">
                                <option value="True"
                                        <c:if test="${rowMenu.ISAVAILABLE == 'True'}">
                                            selected
                                        </c:if>
                                        >Yes</option>
                                <option value="False"
                                        <c:if test="${rowMenu.ISAVAILABLE == 'False'}">
                                            selected
                                        </c:if>
                                        >No</option>
                            </select>
                        </td>
                        <td>
                            <a href="assets/menu-image/${rowMenu.URLIMAGE}" target="_blank">${rowMenu.URLIMAGE}</a>
                            <div class="form-group">
                                <input type="file" name="menuImage" class="form-control-file">
                            </div>
                        </td>
                    </form>
                    <form id="deleteForm${rowMenu.MENUID}" method="post" action="updatemenu.jsp" onsubmit="return confirm('Take note that this action is irreversible! Proceed delete?');">
                        <input type="hidden" name="menuID" value="${rowMenu.MENUID}">
                        <input type="hidden" name="deleteMenu" value="true">
                    </form>
                    <td>
                        <button type="submit" class="btn btn-primary" form="updateForm${rowMenu.MENUID}"><i class="material-icons">save</i></button>&emsp;
                        <button type="submit" class="btn btn-danger" form="deleteForm${rowMenu.MENUID}"><i class="material-icons">delete</i></button>
                    </td>
                    </tr>
                    <c:set var="numRow" value="${numRow + 1}"/>
                </c:forEach>
                </tbody>
            </table>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
        <script src="js/main.js"></script>
    </body>
</html>
