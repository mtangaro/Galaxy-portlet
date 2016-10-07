package it.infn.ct.indigo.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.exception.PortalException;
import com.liferay.portal.kernel.exception.SystemException;
import com.liferay.portal.kernel.util.ParamUtil;
import org.osgi.service.component.annotations.Component;
import java.text.SimpleDateFormat;
import java.io.IOException;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;
import javax.portlet.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.FileNotFoundException;
import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import it.infn.ct.indigo.portlet.Parameter;
import java.util.Random;
import com.google.gson.GsonBuilder;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.File;
import java.io.PrintWriter;

@Component(
	immediate = true,
	property = {
		"com.liferay.portlet.display-category=INFN",
		"com.liferay.portlet.header-portlet-javascript=/js/fg-api.js",
		"com.liferay.portlet.instanceable=true",
		"javax.portlet.display-name=Galaxy Portlet",
		"javax.portlet.init-param.template-path=/",
		"javax.portlet.init-param.view-template=/view.jsp",
		"javax.portlet.resource-bundle=content.Language",
		"javax.portlet.security-role-ref=power-user,user"
	},
	service = Portlet.class
)
//@Controller("galaxyPortlet")
//@RequestMapping(value = "VIEW")
public class GalaxyPortlet extends MVCPortlet {
    final private SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss,SSS");

    private String logEvent(String text) {
        String log = sdf.format(new Date()) + " " + text;
        System.out.println(log);
        return log;
    }

    public void randomNumber(ActionRequest request, ActionResponse renderResponse){
        logEvent("# randomNumber()");
        Random generator = new Random();
        double number = generator.nextDouble();
        request.setAttribute("randomNumber", String.valueOf(number));
    }

    @Override
    public void serveResource(ResourceRequest resourceRequest,
            ResourceResponse resourceResponse) throws IOException,
    PortletException {
        try {
            String ans = ParamUtil.getString(resourceRequest, "json");
            JsonObject jsonObject = new Gson().fromJson(ans, JsonObject.class);

            Gson gson = new GsonBuilder().setPrettyPrinting().create();
            String out = gson.toJson(jsonObject);

            createParamFile(out);
        }
        catch(Exception e) {
            e.printStackTrace(System.out);
        }
        super.serveResource(resourceRequest, resourceResponse);
    }
    
    public void createParamFile(String json) {
        File file = new File("/home/futuregateway/FutureGateway/fgAPIServer/apps/toscaGalaxyTest/parameters.json");
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
    private String readJsonFile(String pathToFile) {
        String json = readFile(pathToFile);
        if(json == null) {
            json = "{  \"parameters\": [    {      \"display\": \"Virtual CPUs Number\",      \"name\": \"number_cpus\",      \"type\": \"list\",      \"value\": [1,2,4,8,16,32,64]    },    {      \"display\": \"Memory size (RAM)\",      \"name\": \"memory_size\",      \"type\": \"list\",      \"value\": [\"1 GB\",\"2 GB\",\"4 GB\",\"8 GB\",\"16 GB\",\"32 GB\"]    },    {      \"display\": \"Volume storage size\",      \"name\": \"volume_storage\",      \"type\": \"list\",      \"value\": [\"100 GB\",\"1 TB\"]    },    {      \"display\": \"SSH public key\",      \"name\": \"instance_key_pub\",      \"type\": \"text\",      \"value\": \"Paste here your public key\"    },    {      \"display\": \"Galaxy version\",      \"name\": \"version\",      \"type\": \"list\",      \"value\": [\"master\"]    },        {      \"display\": \"Instance description (Galaxy brand)\",      \"name\": \"instance_description\",      \"type\": \"text\",      \"value\": \"ELIXIR-ITA Galaxy test\"    },    {      \"display\": \"Galaxy administrator username\",      \"name\": \"user\",      \"type\": \"text\",      \"value\": \"admin username\"    },    {      \"display\": \"Galaxy administrator mail address\",      \"name\": \"admin_email\",      \"type\": \"text\",      \"value\": \"admin mail address\"    },    {      \"display\": \"Disable anonymous access (force everyone to log in)\",      \"name\": \"disable_anonymous_access\",      \"type\": \"list\",      \"value\": [\"Yes\",\"No\"]    },    {      \"display\": \"Galaxy flavor\",      \"name\": \"galaxy_flavour\",      \"type\": \"list\",      \"value\": [\"no-tools\",\"NGS\"]    }  ]}";
        }
        return json;
    }

    @Override
    public void doView(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {
        renderRequest.setAttribute("json-array", readJsonFile("template.json"));
        //renderRequest.setAttribute("token", readFile("/tmp/token"));
        super.doView(renderRequest, renderResponse);
    }
}
