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

/**
 * Servlet class responsible for the activity feed page.
 */
public class FeedServlet extends HttpServlet {

  /**
   * Store class that gives access to Users.
   */
  private UserStore userStore;

  /**
   * Store class that gives access to Conversations.
   */
  private ConversationStore conversationStore;

  /**
   * Store class that gives access to Messages.
   */
  private MessageStore messageStore;

  /**
   * Default number of entries on the feed page
   */
  public static final int DEFAULT_ENTRY_COUNT = 20;

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
   * TODO Implement threshold for fetching entries.
   */
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {

    List<FeedEntry> entries = getSortedEntries();
    //Either display default number of entries or the size of list entries, whichever is smaller
    int feedCount = Math.min(DEFAULT_ENTRY_COUNT, entries.size());
    int remaining = entries.size() - feedCount;

    //Truncate entries to the last newFeedCount amount of entries
    request.setAttribute("entries", entries.subList(entries.size() - feedCount, entries.size()));
    request.setAttribute("feedCount", feedCount);
    request.setAttribute("remaining", remaining);
    request.setAttribute("scrollUp", false);
    request.getRequestDispatcher("/WEB-INF/view/feed.jsp").forward(request, response);
  }

  /**
   * This function fires when a user submits the form on the activity feed page.
   * TODO Implement threshold for fetching entries.
   */
  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {

    List<FeedEntry> entries = getSortedEntries();

    //Either display current feed count + 10 or the size of list entries, whichever is smaller
    int newFeedCount = Math.min(Integer.parseInt(request.getParameter("feedCount")) + 10, entries.size());
    int remaining = entries.size() - newFeedCount;

    //Truncate entries to the last newFeedCount amount of entries
    request.setAttribute("entries", entries.subList(entries.size() - newFeedCount, entries.size()));
    request.setAttribute("feedCount", newFeedCount);
    request.setAttribute("remaining", remaining);
    request.setAttribute("scrollUp", true);
    request.getRequestDispatcher("/WEB-INF/view/feed.jsp").forward(request, response);
  }

  /**
   * Sets the UserStore used by this servlet. This function provides a common setup method for use
   * by the test framework or the servlet's init() function.
   */
  void setMessageStore(MessageStore messageStore) {
    this.messageStore = messageStore;
  }

  public List<FeedEntry> getSortedEntries() {
    List<Conversation> conversations = conversationStore.getAllConversations();
    List<User> users = userStore.getAllUsers();
    List<Message> messages = messageStore.getAllMessages();

    List<FeedEntry> entries = new ArrayList<FeedEntry>();

    entries.addAll(conversations);
    entries.addAll(users);
    entries.addAll(messages);

    Collections.sort(entries, new FeedEntryComparator());

    return entries;
  }

  /**
   * Comparator class that allows for comparision between FeedEntry objects. FeedEntries are compared
   * by their creation time.
   * This allows for chronological sorting of events that happen on the site.
   */
  public static class FeedEntryComparator implements Comparator<FeedEntry> {
    @Override
    public int compare(FeedEntry e1, FeedEntry e2) {
      return e1.getCreationTime().compareTo(e2.getCreationTime());
    }
  }
}
