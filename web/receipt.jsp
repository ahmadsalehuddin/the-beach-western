<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<sql:setDataSource var="beachData" url="jdbc:derby://localhost:1527/thebeachwestern"
                   driver="org.apache.derby.jdbc.ClientDriver"
                   user="app" password="app"/>

<c:if test="${orderID == null}">
    <c:redirect url="addorder.jsp"/>
</c:if>

<jsp:useBean id="now" class="java.util.Date" />
<fmt:formatDate var="currentDate" value="${now}" pattern="dd MMMM yyyy"/>
<fmt:formatDate var="currentTime" value="${now}" pattern="hh:mm:ss"/>

<sql:transaction dataSource="${beachData}">
    <c:if test="${param.placeOrder == 'True'}">
        <sql:update var="updateStatus">
            UPDATE CUSTORDER
            SET ORDERDATE = ?, ORDERTIME = ?
            WHERE ORDERID = ?
            <sql:param value="${currentDate}"/>
            <sql:param value="${currentTime}"/>
            <sql:param value="${orderID}"/>
        </sql:update>
        <c:if test="${updateStatus > 0}">
            <c:remove var="orderID"/>
            <c:redirect url="addorder.jsp">
                <c:param name="orderStatus" value="success"/>
            </c:redirect>
        </c:if>
    </c:if>

    <sql:query var="queryOrderMenu">
        SELECT A.QUANTITY, B.MENUNAME, B.MENUPRICE
        FROM ORDERMENU A, MENU B
        WHERE A.ORDERID = ? AND
        A.MENUID = B.MENUID
        <sql:param value="${orderID}"/>
    </sql:query>  
</sql:transaction>

<fmt:setLocale value="ms_MY"/>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">
        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
        <link href="css/style.css" rel="stylesheet">
        <title>The Beach Western and Chinese Food Muslim &mdash; Receipt</title>
    </head>
    <body>
        <div class="container mt-5 mb-5" style="width: 50%;">
            <div class="row">
                <div class="col-xs-6 col-sm-6 col-md-6">
                    <img src="assets/logo/thebeachwestern.jpg" alt="The Beach Western and Chinese Food" width="40">
                    <address class="mt-2">
                        <strong>The Beach Western and Chinese Food</strong>  
                        <br>
                        Pantai Tok Jembal
                        <br>
                        21300 Kuala Terengganu, Terengganu
                        <br>
                        <abbr title="Phone">Phone:</abbr> 010-000 0000
                    </address>
                </div>
                <div class="col-xs-6 col-sm-6 col-md-6 text-end">
                    <p class="mt-5">
                        <em>Date: ${currentDate}</em>
                    </p>
                    <p>
                        <em>Order Number: ${orderID}</em>
                    </p>
                </div>
            </div>
            <div class="row">
                <div class="text-center">
                    <h1>Receipt</h1>
                </div>
                </span>
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>Food & Beverages</th>
                            <th>Quantity</th>
                            <th class="text-center">Price</th>
                            <th class="text-center">Total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:set var="totalPrice" value="0.0"/>
                        <c:forEach var="rowOrderMenu" items="${queryOrderMenu.rows}">
                            <tr>
                                <td class="col-md-9"><em>${rowOrderMenu.MENUNAME}</em></h4></td>
                                <td class="col-md-1" style="text-align: center"> ${rowOrderMenu.QUANTITY} </td>
                                <td class="col-md-1 text-center"><fmt:formatNumber value="${rowOrderMenu.MENUPRICE}" type="currency"/></td>
                                <td class="col-md-1 text-center"><fmt:formatNumber value="${rowOrderMenu.MENUPRICE * rowOrderMenu.QUANTITY}" type="currency"/></td>
                            </tr>
                            <c:set var="totalPrice" value="${totalPrice + (rowOrderMenu.MENUPRICE * rowOrderMenu.QUANTITY)}"/>
                        </c:forEach>
                        <tr>
                            <td>   </td>
                            <td>   </td>
                            <td class="text-right">
                                <p>
                                    <strong>Subtotal: </strong>
                                </p></td>
                            <td class="text-center">
                                <p>
                                    <strong><fmt:formatNumber value="${totalPrice}" type="currency"/></strong>
                                </p></td>
                        </tr>
                        <tr>
                            <td>   </td>
                            <td>   </td>
                            <td class="text-right"><h4><strong>Total: </strong></h4></td>
                            <td class="text-center text-danger"><h4><strong><fmt:formatNumber value="${totalPrice}" type="currency"/></strong></h4></td>
                        </tr>
                    </tbody>
                </table>
                <div class="text-center">
                    <a href="addorder.jsp">
                        <button type="button" class="col-md-5 btn btn-danger btn-lg">
                            Cancel<span class="glyphicon glyphicon-chevron-right"></span>
                        </button></a>
                    &emsp;&emsp;
                    <button type="submit" form="placeOrderForm" class="col-md-5 btn btn-success btn-lg">
                        Place Order<span class="glyphicon glyphicon-chevron-right"></span>
                    </button>
                </div>
            </div>
        </div>

        <form id="placeOrderForm" method="post" action="receipt.jsp">
            <input type="hidden" name="placeOrder" value="True">
        </form>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
        <script src="js/main.js"></script>
    </body>
</html>
