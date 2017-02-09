<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>


<%@ page import="java.util.List" %>

<%@ page import="com.todolist.myapp.ItemsInList" %>
<%@ page import="com.todolist.myapp.ToDoList" %>
<%@ page import="com.googlecode.objectify.Key" %>
<%@ page import="com.googlecode.objectify.ObjectifyService" %>


<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>
<body>
<%
    //Michael Dadurian

    String list_name = request.getParameter("list_name");
    if (list_name == null){
        list_name = "default";
    }
    pageContext.setAttribute("list_name", list_name);
    UserService user_service = UserServiceFactory.getUserService();
    User curr_user = user_service.getCurrentUser();
    if (curr_user != null){
        pageContext.setAttribute("curr_user", curr_user); //set username

    //display link to sign out
%>
<p> ${fn:escapeXml(curr_user.nickname)} successfully logged in.
        (You can
            <a href="<%= user_service.createLogoutURL(request.getRequestURI()) %>">sign out</a>.)
</p>
<%
     //if not logged in already, sign in

    } else {
%>
<p> <a href="<%= user_service.createLoginURL(request.getRequestURI()) %>">Sign in</a> </p>

<%
    }
%>

</body>
</html>