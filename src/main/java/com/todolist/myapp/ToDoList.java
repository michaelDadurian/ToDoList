//Michael Dadurian
package com.todolist.myapp;

import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;

import java.util.Date;

@Entity
public class ToDoList {
    @Id public String list_name;
    @Index public String list_owner;
    public boolean public_status;
    public Date date_created;

    public ToDoList(){
        date_created = new Date();
    }
}
