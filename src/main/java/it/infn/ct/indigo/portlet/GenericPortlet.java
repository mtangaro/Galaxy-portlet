package it.infn.ct.indigo.portlet;

import com.liferay.portal.kernel.portlet.bridges.mvc.MVCPortlet;
import com.liferay.portal.kernel.util.ParamUtil;
import org.osgi.service.component.annotations.Component;
import javax.portlet.*;
import java.io.IOException;
import java.io.PrintWriter;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import it.infn.ct.indigo.portlet.configuration.Config;

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
    private Config config = new Config();

    @Override
    public void serveResource(ResourceRequest resourceRequest,
            ResourceResponse resourceResponse) throws IOException,
    PortletException {
        try {
            String json = ParamUtil.getString(resourceRequest, "json");
            String path = ParamUtil.getString(resourceRequest, "path");
            String jarray = ParamUtil.getString(resourceRequest, "jarray");

            // create parameter.json file 
            if(!json.equals("")) {
                   JsonObject jsonObject = new Gson().fromJson(json, JsonObject.class);
                   Gson gson = new GsonBuilder().setPrettyPrinting().create();
                   String out = gson.toJson(jsonObject);

                   config.createParamFile(path, out);
            }

            // get application configuration: i.a. path to parameters.json
            if(!jarray.equals("")) {
                String ans = config.readJsonFile(jarray); 
                PrintWriter writer = resourceResponse.getWriter();
                writer.write(ans);
            }
        }
        catch(Exception e) {
            e.printStackTrace(System.out);
        }
        super.serveResource(resourceRequest, resourceResponse);
    }
    
    @Override
    public void doView(RenderRequest renderRequest, RenderResponse renderResponse) throws IOException, PortletException {
        super.doView(renderRequest, renderResponse);
    }
}
