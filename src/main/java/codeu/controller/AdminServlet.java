package codeu.controller;

import codeu.model.data.Conversation;
import codeu.model.data.Message;
import codeu.model.data.User;
import codeu.model.store.basic.ConversationStore;
import codeu.model.store.basic.MessageStore;
import codeu.model.store.basic.UserStore;
import java.util.ArrayList;
import java.util.List;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;


public class AdminServlet extends HttpServlet {

	 /** Store class that gives access to Conversations. */
	  private ConversationStore conversationStore;

	  /** Store class that gives access to Messages. */
	  private MessageStore messageStore;

	  /** Store class that gives access to Users. */
	  private UserStore userStore;	
	
	  /** Set up state for handling chat requests. */
	  @Override
	  public void init() throws ServletException {
	    super.init();
	    setConversationStore(ConversationStore.getInstance());
	    setMessageStore(MessageStore.getInstance());
	    setUserStore(UserStore.getInstance());
	  }

	  /**
	   * Sets the ConversationStore used by this servlet. This function provides a common setup method
	   * for use by the test framework or the servlet's init() function.
	   */
	  void setConversationStore(ConversationStore conversationStore) {
	    this.conversationStore = conversationStore;
	  }

	  /**
	   * Sets the MessageStore used by this servlet. This function provides a common setup method for
	   * use by the test framework or the servlet's init() function.
	   */
	  void setMessageStore(MessageStore messageStore) {
	    this.messageStore = messageStore;
	  }

	  /**
	   * Sets the UserStore used by this servlet. This function provides a common setup method for use
	   * by the test framework or the servlet's init() function.
	   */
	  void setUserStore(UserStore userStore) {
	    this.userStore = userStore;
	  }

	  private List<Message> getAllMessages(List<Conversation> allConversations) {
		  List<Message> messages = new ArrayList<>();
		  for (Conversation c : allConversations) {
			  messages.addAll(messageStore.getMessagesInConversation(c.getId()));
		  }
		  return messages;
	  }
	  
	  @Override
	  public void doGet(HttpServletRequest request, HttpServletResponse response)
	  throws IOException, ServletException {
		  List<Conversation> listOfAllConversations = conversationStore.getAllConversations();
		  request.setAttribute("conversations", listOfAllConversations);
	  
		  List<Message> listOfAllMessages = getAllMessages(listOfAllConversations);
		  request.setAttribute("messages", listOfAllMessages);
	  
		  List<User> listOfAllUsers = userStore.getAllUsers();
		  request.setAttribute("users", listOfAllUsers);
	  
		  request.getRequestDispatcher("/WEB-INF/view/admin.jsp").forward(request, response);
	  }
	  
	
	  
}
