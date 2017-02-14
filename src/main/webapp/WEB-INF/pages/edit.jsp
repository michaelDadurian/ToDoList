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
            <h3>Please Fill in New Item Details</h3>

             Content:
            <div><textarea name="listContent" rows="3" cols="60"></textarea></div>

            Start Date:
            <input type="date" name="startDate" id="startDate" value="${startDate}" >
            End Date:
            <input type="date" name="endDate" id="endDate" value="${endDate}">


            <input type = "hidden" name = "user" value = "${user}">
            <input type = "hidden" name = "listNameInput" value = "${listNameInput}">
            Category:
            <input type = "text" name = "category">
            <div><input type="submit" value="Add ToDo"></div>
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
            <h3>Edit Content<h3>
            <div><textarea name="listContent" rows="3" cols="60"><%=request.getParameter("currContent")%></textarea></div>

            Start Date:
            <input type="date" name="startDate" id="startDate" value="${startDate}">
            End Date:
            <input type="date" name="endDate" id="endDate" value="${endDate}">

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
            <div><input type="submit" value="Confirm Edit"></div>
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

          <table id="list_info" class="sortable" border="1">
            <tr>
                <th>Content</th>
                <th>Options</th>
            </tr>
            <%
            for (Entity ListList : lists){
                pageContext.setAttribute("listContent", ListList.getProperty("listContent"));
                pageContext.setAttribute("category", ListList.getProperty("category"));
                pageContext.setAttribute("completed", ListList.getProperty("completed"));
            %>
              <tr>
                <td>${fn:escapeXml(listContent)}</td>
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
                        <input type = "submit" class = "edit_btn" value = "edit">
                    </form>
                    <form action="/deleteContent" method="post" style = "display:inline">
                        <input type = "hidden" name = "user" value  = "${user}">
                        <input type = "hidden" name = "listNameInput" value  = "${listNameInput}">
                        <input type = "hidden" name = "currContent" value  = "${listContent}">
                        <input type = "hidden" name = "visibility" value = "${listVisibility}">
                        <input type = "submit" class = "delete_btn" value = "delete">
                    </form>

                </td>

                <td><input type="button" value="move up" class="move up" /></td>
                <td><input type="button" value="move down" class="move down" /></td>


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
