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
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>

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

<%-- Start of adding new lists --%>

<div name = "listNameTest">

    <form action="/addToDo" method="post">
        <h3>What would you like to do?<h3>
        <div><textarea name="listContent" rows="3" cols="60"></textarea></div>
        <input type = "hidden" name = "user" value = "${user}">
        <input type = "hidden" name = "listNameInput" value = "${listNameInput}">
        <input type = "hidden" name = "listContent" value = "${listContent}">
        <div><input type="submit" value="Add ToDo"></div>
    </form>

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
        <tr>
            <th>Content</th>
            <th>Options</th>
        </tr>
          <table id="list_info" border="1">

            <%
            for (Entity ListList : lists){
                pageContext.setAttribute("listContent", ListList.getProperty("listContent"));
            %>
              <tr>
                <td>${fn:escapeXml(listContent)}</td>
                <td>

                <%-- Need to go to edit jsp page, controller will take input from edit page --%>
                    <form action = "/edit" style = "display:inline">
                        <input type = "submit" class = "edit_btn" value = "edit">
                    </form>
                    <form action="/deleteList" method="post" style = "display:inline">
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
