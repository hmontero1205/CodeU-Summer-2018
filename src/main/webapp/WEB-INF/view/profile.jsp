<%@ page import="java.util.List" %>
<%@ page import="codeu.model.data.User" %>

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
    <% if(request.getSession().getAttribute("user") != null){ %>
      <a>Hello <%= request.getSession().getAttribute("user") %>!</a>
    <% } else{ %>
      <a href="/login">Login</a>
    <% } %>
    <a href="/about.jsp">About</a>
  </nav>

  <div id="container">

    <% if(request.getAttribute("error") != null){ %>
        <h2 style="color:red"><%= request.getAttribute("error") %></h2>
    <% } %>

    <% if(request.getSession().getAttribute("user") != null){ %>
      <h1>Search for a Friend!</h1>
      <form action="/conversations" method="POST">
          <div class="form-group">
            <label class="form-control-label">Name:</label>
          <input type="text" name="searchedUser">
        </div>

        <button type="submit">Search</button>
      </form>

      <hr/>
    <% } %>

    <h1>This is your profile</h1>

    <hr/>
  </div>
</body>
</html>
