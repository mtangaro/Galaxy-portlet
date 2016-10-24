package it.infn.ct.indigo.portlet;

import java.util.Iterator;
import java.util.List;
import com.google.gson.JsonObject;

public class Application {
    public Integer id;
    public String app;
    public String file;
    public String path;
    public String name;
    public String config;
    public String display;

    public static class array implements Iterable<Parameter>{
        public List<Parameter> apps;
        public Iterator<Parameter> iterator() {
            return this.apps.iterator();
        }
    }
}

