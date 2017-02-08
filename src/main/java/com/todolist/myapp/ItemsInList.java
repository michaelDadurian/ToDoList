//Michael Dadurian

package com.todolist.myapp;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Parent;

import java.lang.String;
import java.util.Date;
import java.util.List;



@Entity
public class ItemsInList {
    @Parent Key<ToDoList>  to_do_list;
    @Id public Long id;

    /**
     *items in list have:
     * -category
     * -description
     * -start and end date
     * -completed (t/f)
     */

    @Index public Date start_date; //probably not optimal
    public Date end_date;
    public String category;
    public String description;
    public boolean completed;



    public ItemsInList(){
        start_date = new Date();
    }

    public ItemsInList(String list_name){
        this();
        if (list_name != null){
            to_do_list = Key.create(ToDoList.class, list_name);
        }else {
            to_do_list = Key.create(ToDoList.class, list_name);
        }

    }

    public ItemsInList(String list_name, String category, String description, boolean completed){
        this(list_name);
        this.category = category;
        this.description = description;
        this.completed = false;
    }

}
