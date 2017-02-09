//Michael Dadurian

package com.todolist.myapp;

import com.googlecode.objectify.Key;
import com.googlecode.objectify.annotation.Entity;
import com.googlecode.objectify.annotation.Id;
import com.googlecode.objectify.annotation.Index;
import com.googlecode.objectify.annotation.Parent;

import java.lang.String;
import java.util.Date;


@Entity
public class ItemsInList {
    @Parent Key<ToDoList>  to_do_list;
    @Id
    private Long id;

    @Index
    private Date start_date; //probably not optimal
    private Date end_date;
    private String category;
    private String description;
    private boolean completed;



    public ItemsInList(){
        setStart_date(new Date());
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
        this.setCategory(category);
        this.setDescription(description);
        this.setCompleted(false);
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    /**
     *items in list have:
     * -category
     * -description
     * -start and end date
     * -completed (t/f)
     */
    public Date getStart_date() {
        return start_date;
    }

    public void setStart_date(Date start_date) {
        this.start_date = start_date;
    }

    public Date getEnd_date() {
        return end_date;
    }

    public void setEnd_date(Date end_date) {
        this.end_date = end_date;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public boolean isCompleted() {
        return completed;
    }

    public void setCompleted(boolean completed) {
        this.completed = completed;
    }
}
