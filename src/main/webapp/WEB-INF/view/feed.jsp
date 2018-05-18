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

<%
  List<FeedEntry> entries = (List<FeedEntry>) request.getAttribute("entries");

  for(FeedEntry f : entries) {
    System.out.printf("Creation Time: %s, ", f.getCreationTime());
    if(f instanceof Message) {
      System.out.printf("Type: Message, User: %s, Content: %s\n", UserStore.getInstance().getUser(((Message) f).getAuthorId()).getName(), ((Message) f).getContent());
      continue;
    }
    if(f instanceof Conversation) {
      System.out.printf("Type: Conversation, Title: %s\n",((Conversation) f).getTitle());
      continue;
    }
    if(f instanceof User) {
      System.out.printf("Type: User, Username: %s\n",((User) f).getName());
      continue;
    }
  }


%>


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
  <a>Hello <%= request.getSession().getAttribute("user") %>!</a>
  <% } else { %>
  <a href="/login">Login</a>
  <% } %>
  <a href="/about.jsp">About</a>
  <a href="/feed">Activity Feed</a>
</nav>


<div id="container">
  <h1>Activity Feed</h1>
</div>
</body>
</html>
