<%@ page import="java.util.List" %>
<%@ page import="codeu.model.data.User" %>
<%
User requestUser = (User) request.getAttribute("requestUser");
%>

<!DOCTYPE html>
<html>
<head>
  <title>Profile</title>
  <link rel="stylesheet" href="/css/main.css">
</head>
<body>

  <nav>
    <a id="navTitle" href="/">CodeU Chat App</a>
    <a href="/conversations">Conversations</a>
    <% if(request.getSession().getAttribute("user") != null) { %>
    <a href="/profile"> Hello <%= request.getSession().getAttribute("user") %>!</a>
    <% } else { %>
      <a href="/login">Login</a>
    <% } %>
    <a href="/about.jsp">About</a>
    <a href="/feed">Activity Feed</a>
  </nav>

  <div id="container">
    <h1><%= requestUser.getName() %>'s Profile Page</h1>

    <h2>About <%= requestUser.getName() %></h2>

    <p><%= requestUser.getBio() %></p>
    <% if(request.getAttribute("error") != null){ %>
        <h2 style="color:red"><%= request.getAttribute("error") %></h2>
    <% } %>

    <% if(String.valueOf(request.getSession().getAttribute("user"))
         .equals(requestUser.getName())) { %>
      <p>Edit Your Profile!</p>
      <form action="/user/<%= request.getSession().getAttribute("user") %>" method="POST">
          <div class="form-group">
            <label class="form-control-label">New Bio:</label>
          <input  type="text" name="inputBio">
        </div>

        <button type="submit">Update</button>
      </form>

      <hr/>
    <% } %>

    <hr/>
  </div>
</body>
</html>
