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

import codeu.model.data.User;
import codeu.model.store.basic.UserStore;
import codeu.model.data.Message;
import codeu.model.store.basic.MessageStore;
import codeu.model.data.Conversation;
import codeu.model.store.basic.ConversationStore;
import java.io.IOException;
import java.time.Instant;
import java.util.UUID;
import java.util.List;
import java.util.ArrayList;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;

public class AdminServletTest {

  public AdminServlet adminServlet;
  private HttpServletRequest mockRequest;
  private HttpSession mockSession;
  private HttpServletResponse mockResponse;
  private RequestDispatcher mockRequestDispatcher;
  private ConversationStore mockConversationStore;
  private MessageStore mockMessageStore;
  private UserStore mockUserStore;

  @Before
  public void setup() {
    adminServlet = new AdminServlet();

    mockRequest = Mockito.mock(HttpServletRequest.class);
    mockSession = Mockito.mock(HttpSession.class);
    Mockito.when(mockRequest.getSession()).thenReturn(mockSession);

    mockResponse = Mockito.mock(HttpServletResponse.class);
    mockRequestDispatcher = Mockito.mock(RequestDispatcher.class);
    Mockito.when(mockRequest.getRequestDispatcher("/WEB-INF/view/admin.jsp"))
        .thenReturn(mockRequestDispatcher);

    mockConversationStore = Mockito.mock(ConversationStore.class);
    adminServlet.setConversationStore(mockConversationStore);

    mockMessageStore = Mockito.mock(MessageStore.class);
    adminServlet.setMessageStore(mockMessageStore);

    mockUserStore = Mockito.mock(UserStore.class);
    adminServlet.setUserStore(mockUserStore);
    }
  
  @Test
  public void testDoGet() throws IOException, ServletException {
	  List<User> fakeUserList = new ArrayList<>();
	    fakeUserList.add(new User(UUID.randomUUID(), "fakeUsername", "fakePassword", Instant.now()));
	    Mockito.when(mockUserStore.getAllUsers()).thenReturn(fakeUserList);
	    
	    List<Conversation> fakeConversationList = new ArrayList<>();
	    fakeConversationList.add(
	        new Conversation(UUID.randomUUID(), fakeUserList.get(0).getId(),"test_conversation", Instant.now()));
	    Mockito.when(mockConversationStore.getAllConversations()).thenReturn(fakeConversationList);

	    List<Message> fakeMessageList = new ArrayList<>();
	    fakeMessageList.add(
	      new Message(UUID.randomUUID(), fakeConversationList.get(0).getId(), fakeUserList.get(0).getId(),
	            "fakeMessage", Instant.now()));
	    Mockito.when(mockMessageStore.getMessagesInConversation(fakeConversationList.get(0).getId())).thenReturn(fakeMessageList);
	  
    adminServlet.doGet(mockRequest, mockResponse);
    Mockito.verify(mockRequest).setAttribute("conversations", fakeConversationList);
    Mockito.verify(mockRequest).setAttribute("messages", fakeMessageList);
    Mockito.verify(mockRequest).setAttribute("users", fakeUserList.size());
    Mockito.verify(mockRequestDispatcher).forward(mockRequest, mockResponse);
  }
}

