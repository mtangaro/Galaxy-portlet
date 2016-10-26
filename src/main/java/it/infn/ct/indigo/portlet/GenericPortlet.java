package it.infn.ct.indigo.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.util.ParamUtil;
import org.osgi.service.component.annotations.Component;
import javax.portlet.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.File;
import java.io.PrintWriter;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=INFN",
		"com.liferay.portlet.header-portlet-javascript=/js/fg-api.js",
		"com.liferay.portlet.instanceable=true",
		"javax.portlet.display-name=Generic Portlet",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
public class GenericPortlet extends MVCPortlet {
    final private SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss,SSS");
    final private String pathToConfigFiles = "/home/futuregateway/FutureGateway/portletConfigFiles/";
    final private String configJsonFile = "generic-portlet-config.json";
    final private String galaxyJsonFile = "galaxy-template.json";  
    final private String lifewatchJsonFile = "lifewatch-template.json"; 
    private List<Application> apps;

    private String logEvent(String text) {
        String log = sdf.format(new Date()) + " " + text;
        System.out.println(log);
        return log;
    }

    private void loadConfig() {
        Parameter parameter = new Gson()
            .fromJson(readJsonFile("generic-portlet-config.json"), Parameter.class);
        apps = parameter.apps;
    }

    @Override
    public void serveResource(ResourceRequest resourceRequest,
            ResourceResponse resourceResponse) throws IOException,
    PortletException {
        try {
            String json = ParamUtil.getString(resourceRequest, "json");
            String path = ParamUtil.getString(resourceRequest, "path");
            String jarray = ParamUtil.getString(resourceRequest, "jarray");

            JsonObject jsonObject = null; 
            if(json != "") {
                   jsonObject = new Gson().fromJson(json, JsonObject.class);
                   Gson gson = new GsonBuilder().setPrettyPrinting().create();
                   String out = gson.toJson(jsonObject);

                   createParamFile(path, out);
            }
            if(jarray != "") {
                for(Application app: apps) {
                    if(jarray.equals(app.name)) {
                        String temp = new Gson().toJson(app);
                        jsonObject = new Gson().fromJson(temp, JsonObject.class);
                        String file = readJsonFile(app.file);
                        if(file == null) {
                            jsonObject.add("config", null);
                        }
                        else {
                            JsonParser parser = new JsonParser();
                            jsonObject.add("config", new Gson().toJsonTree(parser.parse(file).getAsJsonObject()));
                        }
                        break;
                    }
                } 
                PrintWriter writer = resourceResponse.getWriter();
                writer.write(jsonObject.toString());
            }
        }
        catch(Exception e) {
            e.printStackTrace(System.out);
        }
        super.serveResource(resourceRequest, resourceResponse);
    }
    
    public void createParamFile(String path, String json) {
        path = path + "/parameters.json";
        
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
    private String readJsonFile(String fileName) {
        String json = readFile(pathToConfigFiles + fileName);
        return json;
    }

    @Override
    public void doView(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {
        loadConfig();
        renderRequest.setAttribute("apps-array", readJsonFile(configJsonFile));
        super.doView(renderRequest, renderResponse);
    }
}
