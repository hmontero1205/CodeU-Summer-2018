package codeu.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import codeu.model.store.basic.ConversationStore;
import codeu.model.store.basic.MessageStore;
import codeu.model.store.basic.UserStore;
import codeu.model.data.Conversation;
import codeu.model.data.Message;
import codeu.model.data.User;
import java.util.List;

/** Servlet class responsible for the profile page. */
public class ProfileServlet extends HttpServlet {

  /** Store class that gives access to Users. */
  private UserStore userStore;

  /**
   * Set up state for handling conversation-related requests. This method is only called when
   * running in a server, not when running in a test.
   */
  @Override
  public void init() throws ServletException {
    super.init();
    setUserStore(UserStore.getInstance());
  }

  /**
   * Sets the UserStore used by this servlet. This function provides a common setup method for use
   * by the test framework or the servlet's init() function.
   */
  void setUserStore(UserStore userStore) {
    this.userStore = userStore;
  }
  
  @Override
  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {
    String requestUrl = request.getRequestURI();
    String requestUserName = requestUrl.substring("/user/".length());
    User requestUser = userStore.getUser(requestUserName);
    if (requestUser == null) {
      // couldn't find user, redirect to conversation list
      System.out.println("User was null: " + requestUserName);
      response.sendRedirect("/conversations");
      return;
    }

    request.setAttribute("requestUser", requestUser);
    request.getRequestDispatcher("/WEB-INF/view/profile.jsp").forward(request, response);
  }

  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws IOException, ServletException {
    String requestUrl = request.getRequestURI();
    String userName = requestUrl.substring("/user/".length());
    User user = userStore.getUser(userName);
    if (user == null) {
      // couldn't find user, redirect to conversation list
      System.out.println("User was null: " + userName);
      response.sendRedirect("/conversations");
      return;
  }

  //updates the bio of the person submitting the new bio form
  String updatedBio = request.getParameter("inputBio");
  user.setBio(updatedBio);
  userStore.updateUser(user);

  //redirects to the GET
  response.sendRedirect("/user/" + userName);
  }
}
