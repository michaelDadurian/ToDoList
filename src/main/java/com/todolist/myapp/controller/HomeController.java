package com.todolist.myapp.controller;

import java.util.Date;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

@Controller
public class HomeController {

    @RequestMapping("/")
    public String home() {
        return "todolist";
    }


    @RequestMapping("/add")
    public String listAdder(
            @RequestParam(required = true, value = "listNameInput") String listName,
            @RequestParam(required = true, value = "listVisibility") String visibility,

            Model model) {
        UserService userService = UserServiceFactory.getUserService();

        System.out.println("asd" + listName + "ssd");

        Key listKey = KeyFactory.createKey("ListList", listName);

        Entity ListList = new Entity("ListList", listKey);
        ListList.setProperty("user", userService.getCurrentUser());
        ListList.setProperty("ListName", listName);
        ListList.setProperty("Visibility", visibility);

        DatastoreService datastore = DatastoreServiceFactory
                .getDatastoreService();
        datastore.put(ListList);

        return "redirect:/";


    }
}
