// Copyright 2017 Google Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package codeu.controller;

import codeu.model.data.Conversation;
import codeu.model.data.FeedEntry;
import codeu.model.data.Message;
import codeu.model.data.User;
import codeu.model.store.basic.ConversationStore;
import codeu.model.store.basic.MessageStore;
import codeu.model.store.basic.UserStore;
import java.io.IOException;
import java.time.Instant;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/** Servlet class responsible for the conversations page. */
public class FeedServlet extends HttpServlet {

    /** Store class that gives access to Users. */
    private UserStore userStore;

    /** Store class that gives access to Conversations. */
    private ConversationStore conversationStore;

    /** Store class that gives access to Messages. */
    private MessageStore messageStore;

    /**
     * Set up state for handling conversation-related requests. This method is only called when
     * running in a server, not when running in a test.
     */
    @Override
    public void init() throws ServletException {
        super.init();
        setUserStore(UserStore.getInstance());
        setConversationStore(ConversationStore.getInstance());
        setMessageStore(MessageStore.getInstance());
    }

    /**
     * Sets the UserStore used by this servlet. This function provides a common setup method for use
     * by the test framework or the servlet's init() function.
     */
    void setUserStore(UserStore userStore) {
        this.userStore = userStore;
    }

    /**
     * Sets the ConversationStore used by this servlet. This function provides a common setup method
     * for use by the test framework or the servlet's init() function.
     */
    void setConversationStore(ConversationStore conversationStore) {
        this.conversationStore = conversationStore;
    }

    /**
     * This function fires when a user navigates to the conversations page. It gets all of the
     * conversations from the model and forwards to conversations.jsp for rendering the list.
     */
    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {
        List<Conversation> conversations = conversationStore.getAllConversations();
        List<User> users = userStore.getAllUsers();
        List<Message> messages = messageStore.getAllMessages();

        List<FeedEntry> entries = new ArrayList<FeedEntry>();

        entries.addAll(conversations);
        entries.addAll(users);
        entries.addAll(messages);

        Collections.sort(entries, new FeedEntryComporator());

        request.setAttribute("entries", entries);
        request.getRequestDispatcher("/WEB-INF/view/feed.jsp").forward(request, response);
    }

    /**
     * This function fires when a user submits the form on the conversations page. It gets the
     * logged-in username from the session and the new conversation title from the submitted form
     * data. It uses this to create a new Conversation object that it adds to the model.
     */
    /*@Override
    public void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String username = (String) request.getSession().getAttribute("user");
        if (username == null) {
            // user is not logged in, don't let them create a conversation
            response.sendRedirect("/conversations");
            return;
        }

        User user = userStore.getUser(username);
        if (user == null) {
            // user was not found, don't let them create a conversation
            System.out.println("User not found: " + username);
            response.sendRedirect("/conversations");
            return;
        }

        String conversationTitle = request.getParameter("conversationTitle");
        if (!conversationTitle.matches("[\\w*]*")) {
            request.setAttribute("error", "Please enter only letters and numbers.");
            request.getRequestDispatcher("/WEB-INF/view/conversations.jsp").forward(request, response);
            return;
        }

        if (conversationStore.isTitleTaken(conversationTitle)) {
            // conversation title is already taken, just go into that conversation instead of creating a
            // new one
            response.sendRedirect("/chat/" + conversationTitle);
            return;
        }

        Conversation conversation =
                new Conversation(UUID.randomUUID(), user.getId(), conversationTitle, Instant.now());

        conversationStore.addConversation(conversation);
        response.sendRedirect("/chat/" + conversationTitle);
    }*/

    /**
     * Sets the UserStore used by this servlet. This function provides a common setup method for use
     * by the test framework or the servlet's init() function.
     */
    void setMessageStore(MessageStore messageStore) {
        this.messageStore = messageStore;
    }

    private class FeedEntryComporator implements Comparator<FeedEntry> {
        public int compare(FeedEntry e1, FeedEntry e2) {
            return e1.getCreationTime().compareTo(e2.getCreationTime());
        }
    }
}
