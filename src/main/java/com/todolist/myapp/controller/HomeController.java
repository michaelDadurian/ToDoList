package com.todolist.myapp.controller;

import java.util.Date;
import java.util.List;

import com.google.appengine.api.datastore.*;
import com.sun.org.apache.xpath.internal.operations.Mod;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import javax.servlet.http.HttpServletRequest;

@Controller
public class HomeController {

    @RequestMapping("/")
    public String home() {
        return "todolist";
    }

    @RequestMapping("/loggedIn")
    public ModelAndView listGuestbook() {
        UserService userService = UserServiceFactory.getUserService();
        User currentUser = userService.getCurrentUser();

        if (currentUser == null) {
            return new ModelAndView("redirect:"
                    + userService.createLoginURL("/"));
        } else {
            return new ModelAndView("todolist", "welcomeMsg", "You are authenticated, "
                    + currentUser.getNickname());
        }
    }


    @RequestMapping("/add")
    public String listAdder(
            @RequestParam(required = true, value = "listNameInput") String listName,
            @RequestParam(required = true, value = "listVisibility") String visibility,
            Model model) {
        UserService userService = UserServiceFactory.getUserService();

        if(listName.equals("")){
            return "redirect:/";
        }

        Key listKey = KeyFactory.createKey("ListList", listName);

        Entity ListList = new Entity("ListList", listKey);
        ListList.setProperty("user", userService.getCurrentUser());
        ListList.setProperty("ListName", listName);
        ListList.setProperty("Visibility", visibility);

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        datastore.put(ListList);

        return "redirect:/";

    }

    @RequestMapping("/editVisibility")
    public ModelAndView editVisibility(HttpServletRequest request, ModelMap model) {

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

        String listName = request.getParameter("listNameHid");
        String visibility = request.getParameter("listVisibility");

        Query query = new Query("ListList");
        query.addFilter("ListName", Query.FilterOperator.EQUAL, listName);
        PreparedQuery pq = datastore.prepare(query);
        Entity ListList = pq.asSingleEntity();

        ListList.setProperty("ListName", listName);
        ListList.setProperty("Visibility", visibility);


        datastore.put(ListList);

        ModelAndView mav = new ModelAndView("redirect:/");
        //return to list
        return mav;

    }

    @RequestMapping("/deleteList")
    public String listDelete(
            @RequestParam(required = true, value = "listDelHid") String listName,
            Model model) {
        UserService userService = UserServiceFactory.getUserService();

        System.out.println(listName + " " + userService.getCurrentUser());

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query deleteQuery = new Query("ListList");
        deleteQuery.addFilter("ListName", Query.FilterOperator.EQUAL, listName);
        deleteQuery.addFilter("user", Query.FilterOperator.EQUAL, userService.getCurrentUser());
        PreparedQuery pq = datastore.prepare(deleteQuery);
        Entity listEntity = pq.asSingleEntity();

        datastore.delete(listEntity.getKey());

        Key listKey = KeyFactory.createKey("ListList", listName);

        return "redirect:/";

    }

    @RequestMapping("/edit")
    public String listEdit( @RequestParam(required = true, value = "user") String user,
                            @RequestParam(required = true, value = "listNameInput") String listName,
                            @RequestParam(required = true, value = "listVisibility") String visibility) throws EntityNotFoundException {

        UserService userService = UserServiceFactory.getUserService();

        return "edit";

    }


    @RequestMapping("/addToDo")
    public ModelAndView listAddToDo( @RequestParam(required = true, value = "user") String user,
                                     @RequestParam(required = true, value = "listNameInput") String listName,
                                     @RequestParam(required = true, value = "listContent") String content
        ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("listContent "+content);

        UserService userService = UserServiceFactory.getUserService();

        Key listKey = KeyFactory.createKey("ListListContent", listName);
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

        Query query = new Query("ListListContent");

        query.addFilter("listNameInput", Query.FilterOperator.EQUAL, listName);
        query.addFilter("user", Query.FilterOperator.EQUAL, user);
        query.addFilter("listContent", Query.FilterOperator.EQUAL, content);
        System.out.println("Datastore filter User "+user);
        List<Entity> lists = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(100));



        if(lists.isEmpty()) {
            Entity currList = new Entity("ListListContent", listKey);

            currList.setProperty("user", user);
            currList.setProperty("listNameInput", listName);
            currList.setProperty("listContent", content);
            datastore.put(currList);
        }

        ModelAndView mav = new ModelAndView("edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("listContent", content);

        return mav;

    }

    @RequestMapping("/editContent")
    public ModelAndView listEditContent(    @RequestParam(required = true, value = "user") String user,
                                            @RequestParam(required = true, value = "listNameInput") String listName,
                                            @RequestParam(required = true, value = "currContent") String currContent
    ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("currContent "+currContent);

        UserService userService = UserServiceFactory.getUserService();


        ModelAndView mav = new ModelAndView("edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("currContent", currContent);

        return mav;

    }

    @RequestMapping("/confirmEditContent")
    public ModelAndView listConfirmEditContent( @RequestParam(required = true, value = "user") String user,
                                                @RequestParam(required = true, value = "listNameInput") String listName,
                                                @RequestParam(required = true, value = "listContent") String listContent,
                                                @RequestParam(required = true, value = "currContent") String currContent,
                                                @RequestParam(required = true, value = "visibility") String visibility
        ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("content will be changed to: "+listContent);
        System.out.println("currently the content in datastore is: "+currContent);

        UserService userService = UserServiceFactory.getUserService();

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query deleteQuery = new Query("ListListContent");
        deleteQuery.addFilter("listNameInput", Query.FilterOperator.EQUAL, listName);
        deleteQuery.addFilter("user", Query.FilterOperator.EQUAL, user);
        deleteQuery.addFilter("listContent", Query.FilterOperator.EQUAL, currContent);
        PreparedQuery pq = datastore.prepare(deleteQuery);
        Entity listEntity = pq.asSingleEntity();

        datastore.delete(listEntity.getKey());

        Key listKey = KeyFactory.createKey("ListListContent", listName);

        Entity currList = new Entity("ListListContent", listKey);

        currList.setProperty("user", user);
        currList.setProperty("listNameInput", listName);
        currList.setProperty("listContent", listContent);
        datastore.put(currList);

        ModelAndView mav = new ModelAndView("redirect:/edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("listVisibility", visibility);

        return mav;

    }

    @RequestMapping("/deleteContent")
    public ModelAndView listDeleteContent(  @RequestParam(required = true, value = "user") String user,
                                            @RequestParam(required = true, value = "listNameInput") String listName,
                                            @RequestParam(required = true, value = "currContent") String currContent,
                                            @RequestParam(required = true, value = "visibility") String visibility
    ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("currContent "+currContent);

        UserService userService = UserServiceFactory.getUserService();

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query deleteQuery = new Query("ListListContent");
        deleteQuery.addFilter("listNameInput", Query.FilterOperator.EQUAL, listName);
        deleteQuery.addFilter("user", Query.FilterOperator.EQUAL, user);
        deleteQuery.addFilter("listContent", Query.FilterOperator.EQUAL, currContent);
        PreparedQuery pq = datastore.prepare(deleteQuery);
        Entity listEntity = pq.asSingleEntity();

        datastore.delete(listEntity.getKey());

        Key listKey = KeyFactory.createKey("ListListContent", listName);


        ModelAndView mav = new ModelAndView("redirect:/edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("listVisibility", visibility);

        return mav;

    }


    @RequestMapping("/sort")
    public ModelAndView listListSort( @RequestParam(required = true, value = "sortValue") String sortValue,
                                     @RequestParam(required = true, value = "colName") String colName
    ) throws EntityNotFoundException {

        ModelAndView mav = new ModelAndView("todolist");
        if(sortValue.equals("asc"))
            mav.addObject("sortValue", "des");
        else
            mav.addObject("sortValue", "asc");

        mav.addObject("colName", colName);
        return mav;

    }


}



