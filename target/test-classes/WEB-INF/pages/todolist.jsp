<!-- Kenny Chan-->
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
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<script src="http://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>

<body>
<div style="border-bottom: solid #3d37ff">
    <h1>${welcomeMsg}</h1>

    <%
        String listName = "llllllllllllllllllllllllllllllllllllllll213213gy3b21gbgbi";
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
    <h2>Hello, ${fn:escapeXml(user.nickname)}!
        <a href="<%= userService.createLogoutURL("/") %>"><button class="button4" type="button" data-toggle="tooltip" title="Sign Out">&nbsp</button></a></h2>
    <%
    } else {
    %>
    <h2>Hello! Sign In to include your name with greetings you post
        <a href="<%= userService.createLoginURL("/loggedIn") %>"><button class="button9" type="button" data-toggle="tooltip" title="Sign In">&nbsp</button></a>
    </h2>
    <%
        }
    %>

</div>

<%-- Start of adding new lists --%>

<h3>To Do List</h3>
<%
if(userService.getCurrentUser() != null){
%>
<div class="ListNameBorder" style="width: 800px; border: 2px solid #3d37ff; padding: 25px; margin: 25px;" >
    <div name = "listNameTest">
        <form action="/add" method="post">

            <%-- Does not handle empty list name --%>
            Name of To Do List: <input type="text" name="listNameInput">

            <input type="radio" name="listVisibility" value="public"> Public
            <input type="radio" name="listVisibility" value="private" checked = "checked"> Private
            <br>
            <input class="button1" type="submit" data-toggle="tooltip" title="Create a New to do list!" name = "listNameSubmit" value=&nbsp;>

        </form>

        <%
            listName = request.getParameter("listNameInput");
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
</div>
<%}
%>
<%-- End of adding new lists --%>



<%-- Start of display list  --%>

<div class="ListNameBorder" style="width: 800px; border: 2px solid #3d37ff; padding: 25px; margin: 25px;" >
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

    <table class="table table-striped" border="1" cellpadding="10" style="background-color: #eee !important;">
        <thead class="thead-default">
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
        </thead>
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
                    <input class="button5" type="submit" data-toggle="tooltip" title="Add New Item" value=&nbsp;>
                </form>
                <form action="/deleteList" method="post" style = "display:inline">
                    <input type = "hidden" name = "listDelHid" value = "${fn:escapeXml(listName)}">
                    <input class="button6" type="submit" data-toggle="tooltip" title="Remove" value=&nbsp;>
                </form>

            </td>
            <td>
                <form action="/editVisibility" method="post">

                    <input type="radio" name="listVisibility" value="public"> Public
                    <input type="radio" name="listVisibility" value="private" checked = "checked"> Private
                    <input type= "hidden" name="listNameHid" value= "${fn:escapeXml(listName)}">
                    <br>
                    <input type="submit" name = "editVisibilitySubmit" value="Submit">

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
</div>

<%-- End of display list  --%>






</body>
<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src = "https://code.jquery.com/jquery.js"></script>
<!-- Latest compiled and minified JavaScript -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<script>
    $(document).ready(function(){
        $('[data-toggle="tooltip"]').tooltip();
    });
</script>
</html>