package com.todolist.myapp.controller;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import com.google.appengine.api.datastore.*;
import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
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

    //to convert to date format
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
        sdf.setLenient(true);
        binder.registerCustomEditor(Date.class, new CustomDateEditor(sdf, true));
    }

    @RequestMapping("/addToDo")
    public ModelAndView listAddToDo( @RequestParam(required = true, value = "user") String user,
                                     @RequestParam(required = true, value = "listNameInput") String listName,
                                     @RequestParam(required = true, value = "listContent") String content,
                                     @RequestParam(required = true, value = "startDate") String startDate,
                                     @RequestParam(required = true, value = "endDate") String endDate,
                                     @RequestParam(required = true, value = "category") String category
        ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("listContent "+content);
        System.out.println("category: "+category);

        UserService userService = UserServiceFactory.getUserService();

        Key listKey = KeyFactory.createKey("ListListContent", listName);
        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

        Query query = new Query("ListListContent");

        query.addFilter("listNameInput", Query.FilterOperator.EQUAL, listName);
        query.addFilter("user", Query.FilterOperator.EQUAL, user);
        query.addFilter("listContent", Query.FilterOperator.EQUAL, content);
        //query.addFilter("startDate", Query.FilterOperator.EQUAL, startDate);
        //query.addFilter("endDate", Query.FilterOperator.EQUAL, endDate);
        //query.addFilter("category", Query.FilterOperator.EQUAL, category);

        System.out.println("Datastore filter User "+user);
        List<Entity> lists = datastore.prepare(query).asList(FetchOptions.Builder.withLimit(100));



        if(lists.isEmpty()) {
            Entity currList = new Entity("ListListContent", listKey);

            currList.setProperty("user", user);
            currList.setProperty("listNameInput", listName);
            currList.setProperty("listContent", content);
            currList.setProperty("startDate", startDate);
            currList.setProperty("endDate", endDate);
            currList.setProperty("category", category);
            currList.setProperty("completed", false);
            datastore.put(currList);
        }

        ModelAndView mav = new ModelAndView("edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("listContent", content);
        mav.addObject("startDate", startDate);
        mav.addObject("endDate", endDate);
        mav.addObject("category", category);

        return mav;

    }



    @RequestMapping("/editContent")
    public ModelAndView listEditContent(    @RequestParam(required = true, value = "user") String user,
                                            @RequestParam(required = true, value = "listNameInput") String listName,
                                            @RequestParam(required = true, value = "currContent") String currContent,
                                            @RequestParam(required = true, value = "category") String category,
                                            @RequestParam(required = true, value = "completed") String completed,
                                            @RequestParam(required = true, value = "startDate") String startDate,
                                            @RequestParam(required = true, value = "endDate") String endDate




    ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("currContent "+currContent);
        System.out.println("category "+category);
        System.out.println("completed "+completed);

        UserService userService = UserServiceFactory.getUserService();


        ModelAndView mav = new ModelAndView("edit");
        mav.addObject("user", user);
        mav.addObject("listNameInput", listName);
        mav.addObject("currContent", currContent);
        mav.addObject("category", category);
        mav.addObject("completed", completed);
        mav.addObject("startDate", startDate);
        mav.addObject("endDate", endDate);


        return mav;

    }

    @RequestMapping("/confirmEditContent")
    public ModelAndView listConfirmEditContent( @RequestParam(required = true, value = "user") String user,
                                                @RequestParam(required = true, value = "listNameInput") String listName,
                                                @RequestParam(required = true, value = "listContent") String listContent,
                                                @RequestParam(required = true, value = "currContent") String currContent,
                                                @RequestParam(required = true, value = "visibility") String visibility,
                                                @RequestParam(required = true, value = "startDate") String startDate,
                                                @RequestParam(required = true, value = "endDate") String endDate,
                                                @RequestParam(required = true, value = "category") String category,
                                                @RequestParam(required = false, value = "completed") String completed



        ) throws EntityNotFoundException {

        System.out.println("User "+user);
        System.out.println("listNameInput "+listName);
        System.out.println("content will be changed to: "+listContent);
        System.out.println("currently the content in datastore is: "+currContent);
        System.out.println("ConfirmEditContent completed: "+completed);

        UserService userService = UserServiceFactory.getUserService();

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
        Query deleteQuery = new Query("ListListContent");
        deleteQuery.addFilter("listNameInput", Query.FilterOperator.EQUAL, listName);
        deleteQuery.addFilter("user", Query.FilterOperator.EQUAL, user);
        deleteQuery.addFilter("listContent", Query.FilterOperator.EQUAL, currContent);
        //deleteQuery.addFilter("startDate", Query.FilterOperator.EQUAL, startDate);
        //deleteQuery.addFilter("endDate", Query.FilterOperator.EQUAL, endDate);

        PreparedQuery pq = datastore.prepare(deleteQuery);
        Entity listEntity = pq.asSingleEntity();

        datastore.delete(listEntity.getKey());

        Key listKey = KeyFactory.createKey("ListListContent", listName);

        Entity currList = new Entity("ListListContent", listKey);

        currList.setProperty("user", user);
        currList.setProperty("listNameInput", listName);
        currList.setProperty("listContent", listContent);
        currList.setProperty("startDate", startDate);
        currList.setProperty("endDate", endDate);
        currList.setProperty("category", category);
        if(completed == null){
            currList.setProperty("completed", false);
        }else{
            currList.setProperty("completed", true);
        }

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



