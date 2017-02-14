<!-- Nelson Tsui-->

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreService" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory" %>
<%@ page import="com.google.appengine.api.datastore.Entity" %>
<%@ page import="com.google.appengine.api.datastore.FetchOptions" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.google.appengine.api.datastore.Query" %>
<%@ page import="com.google.appengine.api.datastore.PreparedQuery" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<html>
<head>
    <link type="text/css" rel="stylesheet" href="/stylesheets/main.css"/>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
    <script src="http://www.kryogenix.org/code/browser/sorttable/sorttable.js"></script>

      <script type="text/javascript">
      $(document).ready(function(){
          $('#list_info input.move').click(function() {
              var row = $(this).closest('tr');
              if ($(this).hasClass('up'))
                  row.prev().before(row);
              else
                  row.next().after(row);
          });
      });

      </script>

</head>

<body>

<h1>${welcomeMsg}</h1>
<h2> List: <%=request.getParameter("listNameInput")%> <h2>

<%
    pageContext.setAttribute("listNameInput", request.getParameter("listNameInput"));

    UserService userService = UserServiceFactory.getUserService();
    User user = userService.getCurrentUser();
    pageContext.setAttribute("user", user);

    if (user != null) {
        pageContext.setAttribute("user", user);
%>
    <p>Hello, ${fn:escapeXml(user.nickname)}! You can also Sign Out
        <a href="<%= userService.createLogoutURL("/") %>"><button class="button4" type="button" data-toggle="tooltip" title="Sign Out">&nbsp</button></a></p>

<%
} else {
%>
    <p>Hello!
        <a href="<%= userService.createLoginURL("/loggedIn") %>">Sign in</a>
        to include your name with greetings you post.</p>
<%
    }
%>

<%
    String todouser = request.getParameter("user");
    if (todouser == null || todouser == "") {
        todouser = "NULL user?";
    }
    pageContext.setAttribute("user", user);
    System.out.println("current user: " + user);

    String listNameInput = request.getParameter("listNameInput");
    if (listNameInput == null || listNameInput == "") {
        listNameInput = "NULL list name?";
    }
    pageContext.setAttribute("listNameInput", listNameInput);
    System.out.println("current listNameInput: " + listNameInput);
%>

<%-- Start of adding new lists --%>

<div name = "listNameTest">

    <% if(request.getParameter("currContent") == null){
    %>

        <form action="/addToDo" method="post">
            <p>Please Fill in New Item Details</p>

             Content:
            <div><textarea name="listContent" rows="3" cols="60"></textarea></div>

            <p>Start Date (MM/dd/yyyy):</p>
            <input type="text" name="startDate" id="startDate" value="${startDate}" >
            <p>End Date (MM/dd/yyyy):</p>
            <input type="text" name="endDate" id="endDate" value="${endDate}">


            <input type = "hidden" name = "user" value = "${user}">
            <input type = "hidden" name = "listNameInput" value = "${listNameInput}">
            <p>Category:</p>
            <input type = "text" name = "category">
            <div><input class="button3" type="submit" data-toggle="tooltip" title="Save ToDo" value=&nbsp;></div>
        </form>

    <%}
     else{

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query query = new Query("ListListContent");

        Query theQuery = new Query("ListListContent");
        theQuery.addFilter("user", Query.FilterOperator.EQUAL, user);
        theQuery.addFilter("listNameInput", Query.FilterOperator.EQUAL, listNameInput);
        theQuery.addFilter("listContent", Query.FilterOperator.EQUAL, request.getParameter("currContent"));
        theQuery.addFilter("startDate", Query.FilterOperator.EQUAL, request.getParameter("startDate"));
        theQuery.addFilter("endDate", Query.FilterOperator.EQUAL, request.getParameter("endDate"));

        PreparedQuery pq = datastore.prepare(theQuery);
        Entity listEntity = pq.asSingleEntity();

     %>

        <form action="/confirmEditContent" method="post">
            <p>Edit Content<p>
            <div><textarea name="listContent" rows="3" cols="60"><%=request.getParameter("currContent")%></textarea></div>

            Start Date (MM/dd/yyyy):
            <input type="text" name="startDate"  value="${startDate}">
            End Date (MM/dd/yyyy):
            <input type="text" name="endDate" value="${endDate}">


            <input type = "hidden" name = "user" value = "${user}">
            <input type = "hidden" name = "listNameInput" value = "${listNameInput}">

            Category:
            <input type = "text" name = "category" value = "${category}">

            Completed?

            <% if(request.getParameter("completed") != ""){ %>
            <input type = "checkbox" name = "completed" value = "${completed}" checked>
            <% } else{ %>
            <input type = "checkbox" name = "completed" value = "${completed}">
            <% } %>



            <input type = "hidden" name = "currContent" value = "${currContent}">
            <input type = "hidden" name = "visibility" value = "${listVisibility}">
                <div><input class="button3" type="submit" data-toggle="tooltip" title="Save Edit" value=&nbsp;></div>
        </form>


    <%}%>



</div>
<%-- End of adding new lists --%>

<%-- Start of display list  --%>

<div name= "displayList">


    <%
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query query = new Query("ListListContent");

        query.addFilter("listNameInput", Query.FilterOperator.EQUAL, listNameInput);
        query.addFilter("user", Query.FilterOperator.EQUAL, todouser);
        System.out.println("Datastore filter User "+user);
        List<Entity> lists = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(100));

    %>

    <table class="table table-striped sortable" border="1" cellpadding="10" style="background-color: #eee !important;">

    <tr>
                <th>Content</th>
                <th>Category</th>
        <th>Completed</th>
        <th>Start Date</th>
        <th>End Date</th>

                <th></th>
            </tr>
            <%
            for (Entity ListList : lists){
                pageContext.setAttribute("listContent", ListList.getProperty("listContent"));
                pageContext.setAttribute("category", ListList.getProperty("category"));
                pageContext.setAttribute("completed", ListList.getProperty("completed"));
                pageContext.setAttribute("startDate", ListList.getProperty("startDate"));
                pageContext.setAttribute("endDate", ListList.getProperty("endDate"));

            %>
              <tr>
                <td>${fn:escapeXml(listContent)}</td>
                  <td>${fn:escapeXml(category)}</td>
                  <td>${fn:escapeXml(completed)}</td>
                  <td>${fn:escapeXml(startDate)}</td>
                  <td>${fn:escapeXml(endDate)}</td>
                <td>

                <%-- Need to go to edit jsp page, controller will take input from edit page --%>
                    <form action = "/editContent" style = "display:inline">
                        <input type = "hidden" name = "user" value  = "${user}">
                        <input type = "hidden" name = "listNameInput" value  = "${listNameInput}">
                        <input type = "hidden" name = "currContent" value  = "${listContent}">
                        <input type = "hidden" name = "startDate" value = "${startDate}">
                        <input type = "hidden" name = "endDate" value = "${endDate}">
                        <input type = "hidden" name = "category" value = "${category}">
                        <input type = "hidden" name = "completed" value = "${completed}">
                        <input class="button5" type="submit" data-toggle="tooltip" title="Edit Item" value=&nbsp;>
                    </form>
                    <form action="/deleteContent" method="post" style = "display:inline">
                        <input type = "hidden" name = "user" value  = "${user}">
                        <input type = "hidden" name = "listNameInput" value  = "${listNameInput}">
                        <input type = "hidden" name = "currContent" value  = "${listContent}">
                        <input type = "hidden" name = "visibility" value = "${listVisibility}">
                        <input class="button6" type="submit" data-toggle="tooltip" title="Remove" value=&nbsp;>
                    </form>

                </td>

                  <td><input type="button" class="button7 move up" data-toggle="tooltip" title="Move Up" value=&nbsp;></td>
                  <td><input type="button" class="button8 move down" data-toggle="tooltip" title="Move Down" value=&nbsp;></td>


              </tr>
    <%
        } // end of for
    %>
          </table>


    </form>
</div>

<%-- End of display list  --%>








</body>
</html>
