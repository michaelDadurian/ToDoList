<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
</head>

<body>
<h1>${welcomeMsg}</h1>

<%
    String guestbookName = request.getParameter("guestbookName");
    if (guestbookName == null) {
        guestbookName = "default";
    }
    pageContext.setAttribute("guestbookName", guestbookName);
    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    if (user != null) {
        pageContext.setAttribute("user", user);
%>
<p>Hello, ${fn:escapeXml(user.nickname)}! (You can
    <a href="<%= userService.createLogoutURL("/") %>">sign out</a>.)</p>
<%
} else {
%>
<p>Hello!
    <a href="<%= userService.createLoginURL("/loggedIn") %>">Sign in</a>
    to include your name with greetings you post.</p>
<%
    }
%>

<%-- Start of adding new lists --%>

<div name = "listNameTest">
    <form action="/add" method="post">

        <%-- Does not handle empty list name --%>
        Name of To Do List: <input type="text" name="listNameInput">

        <input type="radio" name="listVisibility" value="public"> Public
        <input type="radio" name="listVisibility" value="private"> Private
        <br>
        <input type="submit" name = "listNameSubmit" value="Submit">

    </form>

    <%
        String listName = request.getParameter("listNameInput");
        if (listName == null || listName == "") {
            listName = "defaultListName";
        }
        pageContext.setAttribute("defaultListName", listName);
        System.out.println("List Name: " + listName);
    %>

    <%
        DatastoreService listList = DatastoreServiceFactory.getDatastoreService();
        Key listKey = KeyFactory.createKey("ListList", listName);
        // Run an ancestor query to ensure we see the most up-to-date
        Query listQuery = new Query("HelloList", listKey).addSort("date", Query.SortDirection.DESCENDING);


    %>


</div>
<%-- End of adding new lists --%>



<%-- Start of display list  --%>

<div name= "displayList">
    <form action="/display" method="get">

    <%
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Key todolistKey = KeyFactory.createKey("ListList", listName);
        Query query = new Query("ListList");
        List<Entity> lists = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(100));
        if (lists.isEmpty()){
    %>

        <p>No lists</p>
    <%
        }else {
            for (Entity ListList : lists){
                if (ListList.getProperty("Visibility").equals("public")|| ListList.getProperty("user").equals(user)){
                    pageContext.setAttribute("listName", ListList.getProperty("ListName"));
                    pageContext.setAttribute("listVisibility", ListList.getProperty("Visibility"));
                    pageContext.setAttribute("user", ListList.getProperty("user"));

    %>
                <p>name of list: '${fn:escapeXml(listName)}'
                   visibility: '${fn:escapeXml(listVisibility)}'
                   user: '${fn:escapeXml(user)}'</p>

    <%     }
        }
      }

    %>

    </form>
     </div>






</body>
</html>