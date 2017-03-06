package it.infn.ct.indigo.portlet.configuration;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.IOException;
import java.io.File;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

public class Config {
    private final SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss,SSS");
    private final String PARAMETERS_JSON_FILE = "/parameters.json";
    private final String TEMPLATE_PARAMETERS_JSON_FILE = "/template-parameters.json";
    private final String PROPERTY = "content";

    private String logEvent(String text) {
        String log = sdf.format(new Date()) + " " + text;
        System.out.println(log);
        return log;
    }

    public void createParamFile(String path, String json) {
        path = path + PARAMETERS_JSON_FILE;
        
        File file = new File(path);
        PrintWriter printWriter = null;
        try {
            printWriter = new PrintWriter(file);
            printWriter.print(json);
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            if (printWriter != null) {
                printWriter.close();
            }
        }
    }

    private String readFile(String path) {
        String content = null;
        try {
            if(new File(path).isFile()) {
                content = new String(Files.readAllBytes(Paths.get(path)));
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        return content;
    }

    public String readJsonFile(String path) {
        if(path == null) {
            return null;
        }

        String jsonContent = readFile(path + TEMPLATE_PARAMETERS_JSON_FILE);
        JsonObject obj = new JsonObject();
        if(jsonContent == null) {
            obj.add(PROPERTY, null);
        }
        else {
            JsonParser parser = new JsonParser();
            try {
                obj.add(PROPERTY, parser.parse(jsonContent).getAsJsonObject());
            }
            catch(com.google.gson.JsonSyntaxException e) {
                e.printStackTrace();
                obj.add(PROPERTY, null);
            }
        }
        return obj.toString();
    }
}
