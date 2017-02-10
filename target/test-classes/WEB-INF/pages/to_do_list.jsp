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

<%
    Key<ToDoList> to_do_list = Key.create(ToDoList.class, list_name);

    List<ItemsInList> items_in_list = ObjectifyService.ofy()
        .load()
        .type(ItemsInList.class)
        .ancestor(to_do_list)
        .order("-date")
        .list();

    if (items_in_list.isEmpty()){

%>
<p> List '${fn:escapeXml(list_name)}' has not entries.</p>
<%
    } else {
%>
<p> To Do: </p>
<%
    for (ItemsInList item : items_in_list) {
        pageContext.setAttribute("item_category", item.getCategory());
        pageContext.setAttribute("item_description", item.getDescription());

%>
<p>item category: '${fn:escapeXml(item_category)}'
   item_description: '${fn:escapeXml(item_description)}'</p>
<%
    }
   }
%>

<form action="/sign" method="post">
    <div><textarea name="content" rows="3" cols="60"></textarea></div>
    <div><input type="submit" value="List Name:"/></div>
    <input type="hidden" name="list_name" value="${fn:escapeXml(list_name)}"/>
</form>
<form action="/to_do_list.jsp" method="get">
    <div><input type="text" name="list_name" value="${fn:escapeXml(list_name)}"/></div>
    <div><input type="submit" value="Switch List"/></div>
</form>

</body>
</html>