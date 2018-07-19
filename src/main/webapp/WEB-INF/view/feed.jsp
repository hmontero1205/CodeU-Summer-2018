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
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="codeu.controller.FeedServlet" %>

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
      }

      function toggleHiddenSection(buttonElement) {
          hiddenSection = buttonElement.nextElementSibling;
          if(hiddenSection.style.display == "block") {
              hiddenSection.style.display = "none";
              buttonElement.innerHTML = "Expand"
          } else {
              hiddenSection.style.display = "block";
              buttonElement.innerHTML = "Hide"
          }
      }
  </script>
</head>
<body onload="scrollFeed()">

<nav>
  <a id="navTitle" href="/">ECC Chat</a>
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

  <hr/>

  <div class="feedcontainer">

    <ul>
      <%
        int remainingEntries = (Integer) request.getAttribute("remaining");
        if(remainingEntries > 0) {
      %>
        <li>
          <form action="/feed" method="POST">
            <input type="hidden" name="feedCount" value=<%= request.getAttribute("feedCount")%>>
            <button submit">Show older (<%= remainingEntries%>)</button>
          </form>
        </li>
      <%
        }
        UserStore userStore = UserStore.getInstance();
        List<String> unfollowing = null;
        if(request.getSession().getAttribute("user") != null) {
          User currentUser = userStore.getUser((String) request.getSession().getAttribute("user"));
          unfollowing = new ArrayList<>(Arrays.asList(currentUser.getUnfollowing().split("_")));
        }
        ConversationStore conversationStore = ConversationStore.getInstance();
        //TODO Format date based on user's location
        SimpleDateFormat dateFormat = new SimpleDateFormat("[EEEE MMMM dd yyyy @ hh:mma]");

        /***
         * messageBox stores Messages as entries is iterated over to condense the activity feed.
         * If a Message is encountered that doesn't belong in messageBox or if another FeedEntry is to
         * be displayed, messageBox has its contents displayed and is then emptied.
         */
        List<Message> messageBox = new ArrayList<>();
        for (FeedEntry f : entries) {
          if (f instanceof Message) {
            Message m = (Message) f;
            if(messageBox.size() == 0 || (messageBox.get(0).getAuthorId().equals(m.getAuthorId()) &&
                    messageBox.get(0).getConversationId().equals(m.getConversationId()))) {
              messageBox.add(m);
              continue;
            } else {
              Message mLast = messageBox.get(messageBox.size() - 1);
              if(messageBox.size() == 1) {
                String sender = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitle = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
                <li class="entry">
                  <b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mLast.getContent()%>" to
                  <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                </li>
      <%
              } else {
                //Display messageBox contents and empty messageBox before adding new Message
                String senderHeader = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitleHeader = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
                <li class="entry">
                  <b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + senderHeader%>><%= senderHeader %></a> sent <%= messageBox.size()%> messages to
                  <a href=<%= "/chat/" + convoTitleHeader%>> <%= convoTitleHeader %> </a>
                  <br/>
                  <button class="show-button" onclick="toggleHiddenSection(this)">Expand</button>
                  <div class="hidden-messages">
                    <ul>
      <%
                for(Message mb : messageBox) {
                  String sender = userStore.getUser(mb.getAuthorId()).getName();
                  String convoTitle = conversationStore.getConversationWithUUID(mb.getConversationId()).getTitle();
      %>
                      <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mb.getCreationTime()))) %></b>
                        <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mb.getContent()%>" to
                        <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                      </li>
      <%
                }
      %>
                    </ul>
                  </div>
                </li>
      <%
              }
              messageBox.clear();
              messageBox.add(m);
            }
          }

          if (f instanceof Conversation) {
            if(messageBox.size() > 0) {
              Message mLast = messageBox.get(messageBox.size() - 1);
              if(messageBox.size() == 1) {
                String sender = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitle = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();

      %>
                <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mLast.getContent()%>" to
                  <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                </li>
      <%
              } else {
                //Display messageBox contents and empty messageBox before displaying Conversation
                String senderHeader = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitleHeader = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
                <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + senderHeader%>><%= senderHeader %></a> sent <%= messageBox.size()%> messages to
                  <a href=<%= "/chat/" + convoTitleHeader%>> <%= convoTitleHeader %> </a>
                  <br/>
                  <button class="show-button" onclick="toggleHiddenSection(this)">Expand</button>
                  <div class="hidden-messages">
                    <ul>
      <%
                for(Message mb : messageBox) {
                  String sender = userStore.getUser(mb.getAuthorId()).getName();
                  String convoTitle = conversationStore.getConversationWithUUID(mb.getConversationId()).getTitle();
      %>
                      <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mb.getCreationTime()))) %></b>
                        <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mb.getContent()%>" to
                        <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                      </li>
      <%
                }
      %>
                    </ul>
                  </div>
                </li>
      <%
              }
              messageBox.clear();
            }
            Conversation c = (Conversation) f;
            String creator = userStore.getUser(c.getOwnerId()).getName();
      %>

            <li class="entry"><b><%= String.format(dateFormat.format(Date.from(f.getCreationTime()))) %></b>
              <a href="/"> <%= creator %></a> created a new conversation:
              <a href=<%= "/chat/" + c.getTitle() %>> <%= c.getTitle() %> </a>
            </li>

      <%
          }

          if (f instanceof User) {
            if(messageBox.size() > 0) {
              Message mLast = messageBox.get(messageBox.size() - 1);
              if(messageBox.size() == 1) {
                String sender = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitle = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
                <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mLast.getContent()%>" to
                  <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                </li>
      <%
              } else {
                //Display messageBox contents and empty messageBox before displaying User
                String senderHeader = userStore.getUser(mLast.getAuthorId()).getName();
                String convoTitleHeader = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
                <li class="entry">
                  <b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
                  <a href=<%= "/user/" + senderHeader%>><%= senderHeader %></a> sent <%= messageBox.size()%> messages to
                  <a href=<%= "/chat/" + convoTitleHeader%>> <%= convoTitleHeader %> </a>
                  <br/>
                  <button class="show-button" onclick="toggleHiddenSection(this)">Expand</button>
                  <div class="hidden-messages">
                    <ul>
      <%
                for(Message mb : messageBox) {
                  String sender = userStore.getUser(mb.getAuthorId()).getName();
                  String convoTitle = conversationStore.getConversationWithUUID(mb.getConversationId()).getTitle();
      %>
                      <li class="entry">
                        <b><%= String.format(dateFormat.format(Date.from(mb.getCreationTime()))) %></b>
                        <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mb.getContent()%>" to
                        <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                      </li>
      <%
                }
      %>
                    </ul>
                  </div>
                </li>
      <%
              }
              messageBox.clear();
            }
            User u = (User) f;
      %>
            <li class="entry"><b><%= String.format(dateFormat.format(Date.from(f.getCreationTime()))) %></b> <a href=<%= "/user/" + u.getName()%>> <%= u.getName()%></a> joined the chat app</li>

      <%
          }
        }

        //Display contents of messageBox if it has any
        if(messageBox.size() > 0) {
          Message mLast = messageBox.get(messageBox.size() - 1);
          if(messageBox.size() == 1) {
            String sender = userStore.getUser(mLast.getAuthorId()).getName();
            String convoTitle = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();

      %>
            <li class="entry"><b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
              <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mLast.getContent()%>" to
              <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
            </li>
      <%
          } else {
            String senderHeader = userStore.getUser(mLast.getAuthorId()).getName();
            String convoTitleHeader = conversationStore.getConversationWithUUID(mLast.getConversationId()).getTitle();
      %>
            <li class="entry">
              <b><%= String.format(dateFormat.format(Date.from(mLast.getCreationTime()))) %></b>
              <a href=<%= "/user/" + senderHeader%>><%= senderHeader %></a> sent <%= messageBox.size()%> messages to
              <a href=<%= "/chat/" + convoTitleHeader%>> <%= convoTitleHeader %></a>
              <br/>
              <button class="show-button" onclick="toggleHiddenSection(this)">Expand</button>
              <div class="hidden-messages">
                <ul>
      <%
            for(Message mb : messageBox) {
              String sender = userStore.getUser(mb.getAuthorId()).getName();
              String convoTitle = conversationStore.getConversationWithUUID(mb.getConversationId()).getTitle();
      %>
                  <li class="entry">
                    <b><%= String.format(dateFormat.format(Date.from(mb.getCreationTime()))) %></b>
                    <a href=<%= "/user/" + sender%>><%= sender %></a> sent "<%= mb.getContent()%>" to
                    <a href=<%= "/chat/" + convoTitle%>> <%= convoTitle %> </a>
                  </li>
      <%
            }
      %>
                </ul>
              </div>
            </li>
      <%
          }
          messageBox.clear();
        }
      %>
    </ul>
  </div>

  <%
    //Display Preferences section only if logged in
    if (request.getSession().getAttribute("user") != null) {
  %>

  <div class = container-listing>
    <div class="grid-header">
      Preferences
    </div>
    <div class="listing-name">Users</div>
    <div class="listing-name">Conversations</div>
    <div class="listing">
      <ul>
        <%
          List<User> sortedUsers = userStore.getAllUsers();
          Collections.sort(sortedUsers, new FeedServlet.UserComparator());

          for(User u : sortedUsers) {
            String name = u.getName();
            if(name.equals(request.getSession().getAttribute("user"))) continue;
        %>

        <li class="entry">
          <a href=<%= "/user/" + name %>><%= name %></a>
        <%
          if(unfollowing.contains(u.getId().toString())) {
        %>
          <form style="display:inline" action="/feed" method="POST">
            <input type="hidden" name="follow" value="true"/>
            <input type="hidden" name="entityUUID" value=<%= u.getId().toString()%> />
            <button type="submit"> Follow </button>
          </form>
        <%
          } else {
        %>
          <form style="display:inline" action="/feed" method="POST">
            <input type="hidden" name="follow" value="false"/>
            <input type="hidden" name="entityUUID" value=<%= u.getId().toString()%> />
            <button type="submit"> Unfollow </button>
          </form>
        <%
          }
        %>
        </li>
        <%
          }




        %>
      </ul>
    </div>
    <div class="listing">
      <ul>
        <%
          List<Conversation> sortedConvos = conversationStore.getAllConversations();
          Collections.sort(sortedConvos, new FeedServlet.ConversationComparator());

          for(Conversation c : sortedConvos) {
            String title = c.getTitle();
        %>

        <li class="entry">
          <a href=<%= "/chat/" + title %>><%= title %></a>
          <%
            if(unfollowing.contains(c.getId().toString())) {
          %>
          <form style="display:inline" action="/feed" method="POST">
            <input type="hidden" name="follow" value="true"/>
            <input type="hidden" name="entityUUID" value=<%= c.getId().toString()%> />
            <button type="submit"> Follow </button>
          </form>
          <%
          } else {
          %>
          <form style="display:inline" action="/feed" method="POST">
            <input type="hidden" name="follow" value="false"/>
            <input type="hidden" name="entityUUID" value=<%= c.getId().toString()%> />
            <button type="submit"> Unfollow </button>
          </form>
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

  <%
    }
  %>

</div>
</body>
</html>
