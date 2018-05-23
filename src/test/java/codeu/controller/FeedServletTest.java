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
import java.lang.reflect.Array;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;

public class FeedServletTest {

  private FeedServlet feedServlet;
  private HttpServletRequest mockRequest;
  private HttpSession mockSession;
  private HttpServletResponse mockResponse;
  private RequestDispatcher mockRequestDispatcher;
  private ConversationStore mockConversationStore;
  private MessageStore mockMessageStore;
  private UserStore mockUserStore;

  @Before
  public void setup() {
    feedServlet = new FeedServlet();

    mockRequest = Mockito.mock(HttpServletRequest.class);
    mockSession = Mockito.mock(HttpSession.class);
    Mockito.when(mockRequest.getSession()).thenReturn(mockSession);

    mockResponse = Mockito.mock(HttpServletResponse.class);
    mockRequestDispatcher = Mockito.mock(RequestDispatcher.class);
    Mockito.when(mockRequest.getRequestDispatcher("/WEB-INF/view/feed.jsp"))
        .thenReturn(mockRequestDispatcher);

    mockConversationStore = Mockito.mock(ConversationStore.class);
    feedServlet.setConversationStore(mockConversationStore);

    mockMessageStore = Mockito.mock(MessageStore.class);
    feedServlet.setMessageStore(mockMessageStore);

    mockUserStore = Mockito.mock(UserStore.class);
    feedServlet.setUserStore(mockUserStore);
  }

  @Test
  public void testDoGet() throws IOException, ServletException {
    ArrayList<User> fakeUserList = new ArrayList<>();
    fakeUserList.add(new User(UUID.randomUUID(), "fakenname", "fakepass", Instant.now()));

    ArrayList<Conversation> fakeConversationList = new ArrayList<>();
    fakeConversationList.add(
        new Conversation(UUID.randomUUID(), fakeUserList.get(0).getId(),"test_conversation", Instant.now()));

    ArrayList<Message> fakeMessageList = new ArrayList<>();
    fakeMessageList.add(
        new Message(UUID.randomUUID(), fakeConversationList.get(0).getId(), fakeUserList.get(0).getId(),
            "fake content", Instant.now()));

    List<FeedEntry> fakeEntryList = new ArrayList<FeedEntry>();
    fakeEntryList.addAll(fakeConversationList);
    fakeEntryList.addAll(fakeUserList);
    fakeEntryList.addAll(fakeMessageList);
    Collections.sort(fakeEntryList, new FeedServlet.FeedEntryComparator());

    Mockito.when(mockUserStore.getAllUsers()).thenReturn(fakeUserList);
    Mockito.when(mockConversationStore.getAllConversations()).thenReturn(fakeConversationList);
    Mockito.when(mockMessageStore.getAllMessages()).thenReturn(fakeMessageList);

    feedServlet.doGet(mockRequest, mockResponse);

    Mockito.verify(mockRequest).setAttribute("entries", fakeEntryList);
    Mockito.verify(mockRequestDispatcher).forward(mockRequest, mockResponse);
  }
}
