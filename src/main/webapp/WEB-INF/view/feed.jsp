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
<%@ page import="codeu.model.data.FeedEntry" %>
<%@ page import="codeu.model.data.Message" %>
<%@ page import="codeu.model.data.Conversation" %>
<%@ page import="codeu.model.data.User" %>
<%@ page import="codeu.model.store.basic.ConversationStore" %>
<%@ page import="codeu.model.store.basic.UserStore" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%List<FeedEntry> entries = (List<FeedEntry>) request.getAttribute("entries");%>


<!DOCTYPE html>
<html>
<head>
  <title>Activity Feed</title>
  <link rel="stylesheet" href="/css/main.css">
  <script>
      // scroll the chat div to the bottom
      function scrollFeed() {
          <%
            if (!(Boolean) request.getAttribute("scrollUp")) {
          %>
              var feedContainer = document.getElementsByClassName('feedcontainer');
              feedContainer.scrollTop = feedContainer.scrollHeight;
          <%
            }
          %>
      };
  </script>
</head>
<body onload="scrollFeed()">

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
  <% if (request.getSession().getAttribute("user").equals("charmainechan08")) { %>
         <a href="/admin">Admin Page</a>
     <% } %>
</nav>


<div id="container">
  <h1>Activity Feed</h1>

  <hr/>

  <div class="feedcontainer">

    <ul>
      <%
        int remainingEntries = (Integer) request.getAttribute("remaining");
        if (remainingEntries > 0) {
      %>
      <li>
        <form action="/feed" method="POST">
          <input type="hidden" name="feedCount" value=<%= request.getAttribute("feedCount")%>>
          <button type="submit">Show more(<%= remainingEntries %>)</button>
        </form>
      </li>
      <%
        }
        UserStore userStore = UserStore.getInstance();
        ConversationStore conversationStore = ConversationStore.getInstance();
        //TODO Format date based on user's location
        SimpleDateFormat dateFormat = new SimpleDateFormat("[EEEE MMMM dd yyyy @ hh:mma]");

        for (FeedEntry f : entries) {
      %>

      <li>

      <%
          String date = String.format(dateFormat.format(Date.from(f.getCreationTime())));
      %>
        <b>
          <%= date %>
        </b>

      <%
          if (f instanceof Message) {
            Message m = (Message) f;
            String sender = userStore.getUser(m.getAuthorId()).getName();
            String convoTitle = conversationStore.getConversationWithUUID(m.getConversationId()).getTitle();
      %>
        <a href="/"><%= sender %></a> sent a message to <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
      <%
          }
          if (f instanceof Conversation) {
            Conversation c = (Conversation) f;
            String creator = userStore.getUser(c.getOwnerId()).getName();
      %>

        <a href="/"> <%= creator %></a> created a new conversation:
        <a href=<%= "/chat/" + c.getTitle() %>> <%= c.getTitle() %> </a>

      <%
          }
          if (f instanceof User) {
            User u = (User) f;
      %>
        <a href="/"> <%= u.getName()%></a> joined the chat app

      <%
          }
      %>

      </li>

      <%
        }
      %>
    </ul>
  </div>
</div>
</body>
</html>
