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
        <input type="radio" name="listVisibility" value="private" checked = "checked"> Private
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


    <%
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Key todolistKey = KeyFactory.createKey("ListList", listName);
        Query query = query = new Query("ListList");
        if(request.getParameter("colName") == null && request.getParameter("sortValue") == null){
            query = new Query("ListList").addSort("ListName", Query.SortDirection.ASCENDING);
        }else if(request.getParameter("sortValue").equals("asc")){
            query = new Query("ListList").addSort(request.getParameter("colName"), Query.SortDirection.ASCENDING);
        } else {
            query = new Query("ListList").addSort(request.getParameter("colName"), Query.SortDirection.DESCENDING);
        }

        List<Entity> lists = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(100));

        if (lists.isEmpty()){
    %>

        <p>No lists</p>

    <%
        } else {
    %>

          <table id="list_info" border="1">
            <tr>
                <th>
                    <form name="form1" action = "/sort" method = "post">
                        <input type = "hidden" name = "sortValue" value  = "${sortValue}">
                        <input type = "hidden" name = "colName" value  = "ListName">
                        <input name = "tableButton" type = "submit" value = "List Name">
                    </form>
                </th>
                <th>
                    <form name="form1" action = "/sort" method = "post">
                        <input type = "hidden" name = "sortValue" value  = "${sortValue}">
                        <input type = "hidden" name = "colName" value  = "Visibility">
                        <input name = "tableButton" type = "submit" value = "Visibility">
                    </form>
                </th>
                <th>
                    <form name="form1" action = "/sort" method = "post">
                        <input type = "hidden" name = "sortValue" value  = "${sortValue}">
                        <input type = "hidden" name = "colName" value  = "user">
                        <input name = "tableButton" type = "submit" value = "Owner">
                    </form>
                </th>
                <th>Options</th>
            </tr>
            <%
            /*
            if(request.getParameter("tableButton") != null) {
                colName = request.getParameter("tableButton")
            }*/


            for (Entity ListList : lists){
                if (ListList.getProperty("Visibility").equals("public")|| ListList.getProperty("user").equals(user)){
                    pageContext.setAttribute("listName", ListList.getProperty("ListName"));
                    pageContext.setAttribute("listVisibility", ListList.getProperty("Visibility"));
                    pageContext.setAttribute("user", ListList.getProperty("user"));
            %>
              <tr>
                <td>${fn:escapeXml(listName)}</td>
                <td>${fn:escapeXml(listVisibility)}</td>
                <td>${fn:escapeXml(user)}</td>
                <td>
                <%
                    if(ListList.getProperty("user").equals(user)){
                %>

                <%-- Need to go to edit jsp page, controller will take input from edit page --%>
                    <form action = "/edit" style = "display:inline">
                        <input type = "hidden" name = "user" value = "${user}">
                        <input type = "hidden" name = "listNameInput" value = "${listName}">
                        <input type = "hidden" name = "listVisibility" value = "${listVisibility}">
                        <input type = "submit" class = "edit_btn" value = "edit">
                    </form>
                    <form action="/deleteList" method="post" style = "display:inline">
                        <input type = "hidden" name = "listDelHid" value = "${fn:escapeXml(listName)}">
                        <input type = "submit" class = "delete_btn" value = "delete">
                    </form>
                    

                <%}%>
                </td>
              </tr>
    <%
            } // end of if
        } // end of for
    %>
    </table>
    <%
    } // end of else
    %>

    </form>
     </div>

<%-- End of display list  --%>






</body>
</html>
