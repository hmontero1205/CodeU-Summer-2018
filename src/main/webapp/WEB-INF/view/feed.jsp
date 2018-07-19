<%--
  Copyright 2017 Google Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
--%>
<%@ page import="java.util.List" %>
<%@ page import="codeu.model.data.FeedEntry" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="codeu.model.data.Message" %>
<%@ page import="codeu.model.data.Conversation" %>
<%@ page import="codeu.model.data.User" %>
<%@ page import="codeu.model.store.basic.UserStore" %>
<%@ page import="java.util.Date" %>

<%List<FeedEntry> entries = (List<FeedEntry>) request.getAttribute("entries");%>


<!DOCTYPE html>
<html>
<head>
  <title>Activity Feed</title>
  <link rel="stylesheet" href="/css/main.css">
</head>
<body>

<nav>
  <a id="navTitle" href="/">CodeU Chat App</a>
  <a href="/conversations">Conversations</a>
  <% if (request.getSession().getAttribute("user") != null) { %>
  <a href = "/profile"> Hello <%= request.getSession().getAttribute("user") %>!</a>
  <% } else { %>
  <a href="/login">Login</a>
  <% } %>
  <a href="/about.jsp">About</a>
  <a href="/feed">Activity Feed</a>
</nav>


<div id="container">
  <h1>Activity Feed</h1>
  <div class="feedcontainer">

    <ul class="mdl-list">
      <%
        UserStore userStore = UserStore.getInstance();
        for (FeedEntry f : entries) {
          String content = String.format("%s, ", Date.from(f.getCreationTime()));
          if (f instanceof Message) {
            Message m = (Message) f;
            content += String.format("Type: Message, User: %s, Content: %s\n",
                    userStore.getUser(m.getAuthorId()).getName(), m.getContent());
          }

          if (f instanceof Conversation) {
            Conversation c = (Conversation) f;
            content += String.format("Type: Conversation, Title: %s, Owner: %s\n", c.getTitle(),
                    userStore.getUser(c.getOwnerId()).getName());
          }

          if (f instanceof User) {
            User u = (User) f;
            content += String.format("Type: User, Username: %s\n", u.getName());
          }
      %>

      <li><%= content %>
      </li>

      <%
        }
      %>
    </ul>
  </div>
</div>
</body>
</html>
