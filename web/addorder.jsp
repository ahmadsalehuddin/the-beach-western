<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<sql:setDataSource var="beachData" url="jdbc:derby://localhost:1527/thebeachwestern"
                   driver="org.apache.derby.jdbc.ClientDriver"
                   user="app" password="app"/>

<%-- session scope: orderID --%>

<%-- create new cart/order --%>
<sql:transaction dataSource="${beachData}">
    <c:if test="${orderID == null}">
        <sql:update>
            INSERT INTO CUSTORDER (ORDERDATE, ORDERTIME, ISCOMPLETE) VALUES (?, ?, ?)
            <sql:param value=""/>
            <sql:param value=""/>
            <sql:param value="False"/>
        </sql:update>
        <sql:query var="latestOrderID">
            SELECT ORDERID FROM CUSTORDER ORDER BY ORDERID DESC FETCH FIRST ROW ONLY
        </sql:query>  
        <c:set var="orderID" value="${latestOrderID.rows[0].ORDERID}" scope="session"/>
    </c:if>

    <%-- create new or update existing ORDERMENU --%>
    <c:if test="${orderID != null && param.menuID != null && param.quantity != 0}">
        <c:set var="menuID" value="${param.menuID}"/>
        <sql:query var="checkMenuID">
            SELECT * FROM ORDERMENU 
            WHERE MENUID = ? AND ORDERID = ?
            FETCH FIRST ROW ONLY
            <sql:param value="${menuID}"/>
            <sql:param value="${orderID}"/>
        </sql:query>
        <c:choose>
            <c:when test="${checkMenuID.rows[0] != null}">
                <sql:update>
                    UPDATE ORDERMENU SET QUANTITY = ?
                    WHERE ORDERMENUID = ?
                    <sql:param value="${param.quantity + checkMenuID.rows[0].QUANTITY}"/>
                    <sql:param value="${checkMenuID.rows[0].ORDERMENUID}"/>
                </sql:update>
            </c:when>
            <c:otherwise>
                <sql:update>
                    INSERT INTO ORDERMENU (QUANTITY, MENUID, ORDERID) 
                    VALUES (?, ?, ?)
                    <sql:param value="${param.quantity}"/>
                    <sql:param value="${menuID}"/>
                    <sql:param value="${orderID}"/>
                </sql:update>
            </c:otherwise>
        </c:choose>

        <c:remove var="menuID"/>
    </c:if>

    <%-- clear cart when 'Clear All' button is clicked --%>
    <c:if test="${orderID != null && param.clearCart == 'True'}">
        <sql:update>
            DELETE FROM ORDERMENU
            WHERE ORDERID = ?
            <sql:param value="${orderID}"/>
        </sql:update>
    </c:if>

    <%-- get total price and quantity in the cart --%>
    <sql:query var="queryOrderMenu">
        SELECT QUANTITY, MENUID
        FROM ORDERMENU
        WHERE ORDERID = ?
        <sql:param value="${orderID}"/>
    </sql:query>
    <c:set var="totalPrice" value="0.0"/>
    <c:set var="totalQuantity" value="0"/>
    <c:forEach var="rowOrderMenu" items="${queryOrderMenu.rows}">
        <sql:query var="getPrice">
            SELECT MENUPRICE FROM MENU
            WHERE MENUID = ?
            <sql:param value="${rowOrderMenu.MENUID}"/>
        </sql:query>
        <c:set var="totalPrice" value="${totalPrice + (getPrice.rows[0].MENUPRICE * rowOrderMenu.QUANTITY)}"/>
        <c:set var="totalQuantity" value="${totalQuantity + rowOrderMenu.QUANTITY}"/>
    </c:forEach>

    <%-- get all the menu from database --%>
    <sql:query var="menuQuery">
        SELECT * FROM MENU
    </sql:query>
</sql:transaction>

<fmt:setLocale value="ms_MY"/>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="en">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <link href="css/style.css" rel="stylesheet">
        <title>The Beach Western and Chinese Food Muslim &mdash; Food &amp; Beverages Menu</title>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-light bg-light p-2">
            <div class="container">
                <a class="navbar-brand" href="#">
                    <img src="assets/logo/thebeachwestern.jpg" alt="" width="30" height="30" class="d-inline-block align-text-top">&emsp;
                    The Beach Western and Chinese Food Muslim
                </a>
                <div class="navbar-nav mr-auto mt-2 mt-lg-0" id="navbarSupportedContent">
                    <button class="btn btn-danger" type="submit" form="clearForm">Clear All</button>&emsp;
                    <a href="<c:choose><c:when test="${totalQuantity > 0}">receipt.jsp</c:when><c:otherwise>#</c:otherwise></c:choose>">
                        <button class="btn btn-success"><b>Proceed to Summary:</b> 
                            <fmt:formatNumber value="${totalPrice}" type="currency"/> (${totalQuantity} items)</button>
                    </a>
                </div>
            </div>
        </nav>

        <div class="container">
            <h2 class="mt-4">Food &amp; Beverages Menu</h2>
            
            <c:if test="${param.orderStatus == 'success'}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <strong>Woohoo!</strong> Your order has been placed!
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            
            <p class="mt-4">Order Number: ${orderID}</p>

            <div class="mt-2 row row-cols-1 row-cols-md-3 g-4 text-center food-menu">
                <c:forEach var="rowMenu" items="${menuQuery.rows}">
                    <div class="col">
                        <div class="card h-100 shadow-sm mb-3 bg-white rounded">
                            <img src="assets/menu-image/${rowMenu.URLIMAGE}" class="card-img-top" alt="${rowMenu.MENUNAME}">
                            <div class="card-body">
                                <h5 class="card-title">${rowMenu.MENUNAME}</h5>
                                <p class="card-text"><fmt:formatNumber value="${rowMenu.MENUPRICE}" type="currency"/></p>
                                <form id="addToCart-for-${rowMenu.MENUID}" method="post" action="addorder.jsp">
                                    <input type="hidden" name="menuID" value="${rowMenu.MENUID}">
                                    <input type="hidden" name="menuPrice" value="${rowMenu.MENUPRICE}">
                                    Quantity: <input name="quantity" type="number" value="0" min="0" max="99" required <c:if test='${rowMenu.ISAVAILABLE == false}'>disabled</c:if>><br><br>
                                    <a class="btn btn-dark <c:if test='${rowMenu.ISAVAILABLE == false}'>disabled</c:if>" href="javascript:{}" onclick="<c:if test="${rowMenu.ISAVAILABLE == true}">document.getElementById('addToCart-for-${rowMenu.MENUID}').submit();</c:if>"><c:if test="${rowMenu.ISAVAILABLE == true}">Add to Cart</c:if><c:if test='${rowMenu.ISAVAILABLE == false}'>Unavailable</c:if></a>
                                </form>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>    

        <form id="clearForm" method="post" action="addorder.jsp">
            <input type="hidden" name="clearCart" value="True">
        </form>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
        <script src="js/main.js"></script>
    </body>
</html>