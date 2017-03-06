<%@ include file="/init.jsp" %>

        <script type="text/javascript">
            /*
             * All the web app needs to configure are the following
             */
            var paramJson = { parameters: {} };
            var defaultApps;
            var myJson = paramJson ;
            var defaultJson = myJson;
            var application;
            
            var token = null;
            var jobLimit = 5;
            var Jdiv = 0;
            var LI="LI_0";
            var infoMap = new Object();
            var jsonArr; 

            var webapp_settings = {
                apiserver_url: ''
               ,apiserver_path : '/apis'
               ,apiserver_ver  : 'v1.0'
               ,app_id         : 0               
            };
            function changeApp(app_name, app_id) {
                $('#requestButton').prop('disabled', false);
                $('#jsonButton').prop('disabled', false);
                $('#mainTitle').html(app_name+" application");
                for(var i=0; i<defaultApps.applications.length; i++) {
                    if(defaultApps.applications[i].id == app_id) {
                        application = defaultApps.applications[i];
                        webapp_settings.app_id = defaultApps.applications[i].id;
                    }
                }
                callServer("json", getPath(application));
            }
            function welcome() {
                defaultApps = getApplicationsJson();
                $('#jobsDiv').html('');
                var content = '';
                for(var i=0; i<defaultApps.applications.length; i++) {
                    content += '<li><a href="javascript:void(0)" onClick="changeApp(\'';
                    content += defaultApps.applications[i].name+'\',\''+defaultApps.applications[i].id+'\')">';
                    content += defaultApps.applications[i].name+'</a></li>';
                    $('#dropmenu').html(content);
                }
                if(defaultApps.applications.length > 0) {
                    application = defaultApps.applications[0];
                }
            }
            /*
             * Change variable below to change delay of check status loop
             */
            var TimerDelay = 15000;

            /*
             * Page initialization
             */
            $(document).ready(function() {
                $('#confirmDelete').on('show.bs.modal', function (e) {
                    $message = $(e.relatedTarget).attr('data-message');
                    $(this).find('.modal-body p').text($message);
                    $title = $(e.relatedTarget).attr('data-title');
                    $job_id = $(e.relatedTarget).attr('data-data');
                    $(this).find('.modal-title').text($title);
                    $('#job_id').attr('data-value', $job_id)
                    $('#confirmJobDel').show();
                    $('#cancelJobDel').text('Cancel')
                });
                // Form confirm (yes/ok) handler, submits form 
                $('#confirmDelete').find('.modal-footer #confirmJobDel').on('click', function(e){
                    $job_id = $('#job_id').attr('data-value');
                    cleanJob($job_id);              
                });
                setTimeout(checkJobs, TimerDelay); // Initialize the job check loop
            });     
            function printDefault() {
                out = '<p><b>job identifier </b></br>';
                out += '<input type="text" maxlength="50" id="jobDescription" class="form-control"></p>';
                document.getElementById("modalContent").innerHTML = out;
            }
            function printJsonArray() {
                jsonArr = {};
                jsonTab = {};
                if(myJson) {
                    jsonArr = myJson.parameters;
                    jsonTab = myJson.tabs;
                }
                var i;
                var k;
                printDefault();
                tabBegin = '<ul class="nav nav-tabs">'; 
                var tabs = null;
                var makeTabs = false;
                var maxTab = 0;
                if(jsonTab != null) {
                    maxTab = jsonTab.length;
                    tabs = new Array(maxTab);
                    makeTabs = true;
                    for(var i=0; i<maxTab; i++) {
                        if(i == 0) {
                            tabBegin += '<li class="active"><a data-toggle="tab" href="#menu'+i+'">'+jsonTab[i]+'</a></li>';
                        }
                        else {
                            tabBegin += '<li><a data-toggle="tab" href="#menu'+i+'">'+jsonTab[i]+'</a></li>';
                        }
                        tabs[i] = '';
                    }
                }
                tabBegin += '</ul>'; 
                var out;
                var globalOut='';
                for(var i = 0; i < jsonArr.length; i++) {
                    out = '';
                    if(jsonArr[i].hasOwnProperty('display')){
                        out += '<p><b>' + jsonArr[i].display + '</b>';
                    }
                    else {
                        out += '<p><b>' + jsonArr[i].name + '</b>';
                    }
                    switch(jsonArr[i].type) {
                        case "password":
                            out += '<input type="password" maxlength="50" id="param_'+jsonArr[i].name
                                +'" class="form-control" value="' + jsonArr[i].value + '"/></br>';
                            break;
                        case "text":
                            out += '<input type="text" id="param_'+jsonArr[i].name
                                +'" class="form-control" value="' + jsonArr[i].value + '"/></br>';
                            break;
                        case "radio":    
                            out += '<div id="param_'+jsonArr[i].name+'" class="radio">';
                            for(k = 0; k < jsonArr[i].value.length; k++) {
                                out += '<label><input type="radio" name="'+jsonArr[i].name 
                                    +'" value="'+jsonArr[i].value[k]+'"';
                                if(k == 0) {
                                    out += ' checked';
                                }
                                out += '>'+jsonArr[i].value[k]+'</label></br>';
                            }
                            out += '</div>';
                            break;
                        case "list":
                            out += '<div class="form-group">';
                            out += '<select class="form-control" id="param_'+jsonArr[i].name+'">'
                                for(k = 0; k < jsonArr[i].value.length; k++) {
                                    out += '<option>'+jsonArr[i].value[k]+'</option>'
                                }
                            out += '</select></div>';
                            break;
                    }
                    out += '</p>';
                    if((jsonArr[i].tab != null) && makeTabs) {
                        var index = jsonArr[i].tab;
                        if(index < maxTab) {
                            tabs[index] += out;
                        }
                        else {
                            globalOut += out;
                        }
                    }
                    else {
                        globalOut += out;
                    }
                }
                if(jsonTab != null) {
                    out = '<div id="params-modal">';
                    out += globalOut;
                    out += tabBegin;
                    out += '<div class="tab-content">';
                    for(var i=0; i < jsonTab.length; i++) {
                        if(i == 0) {
                            out += '<div id="menu'+i+'" class="tab-pane fade in active">';
                        }
                        else {
                            out += '<div id="menu'+i+'" class="tab-pane fade">';
                        }
                        out += tabs[i];
                        out += '</div>';
                    }
                    out += '</div>';
                    out += '</div>';
                }
                else {
                    out = '<div id="params-modal">';
                    out += globalOut;
                    out += '</div>';
                }
                var myDiv = document.getElementById("modalContent");
                myDiv.innerHTML = myDiv.innerHTML + out;
            }
            function getParams() {
                jsonApp = {};
                if(myJson != null) {
                    jsonArr = myJson.parameters;
                }

                paramJson = { parameters: {} };
                for(var i=0; i<jsonArr.length; i++) {
                    switch(jsonArr[i].type) {
                        case "radio":
                            var out = $('input[name='+jsonArr[i].name+']:checked').val();
                            paramJson.parameters[jsonArr[i].name] = out;
                            break;
                        default:
                            var out = $('#param_'+jsonArr[i].name).val();
                            paramJson.parameters[jsonArr[i].name] = out;
                    }
                }
                callServer("submit", getPath(application));
            }
            function callServer(call, opt) {
                switch(call) {
                    case "submit":
                        var myData = {
                            <portlet:namespace />json: JSON.stringify(paramJson),
                            <portlet:namespace />path: opt
                        };
                        AUI().use('aui-io-request', function(A){
                            A.io.request('<%=resourceURL.toString()%>', {
                                dataType: 'json',
                                method: 'post',
                                data: myData
                            });
                        });
                        break;
                    case "json":
                        var myData = {<portlet:namespace />jarray: opt};
                        AUI().use('aui-io-request', function(A){
                                A.io.request('<%=resourceURL.toString()%>', {
                                dataType: 'json',
                                method: 'post',
                                data: myData,
                                on: {
                                    success: function() {
                                        var content = this.get('responseData');
                                        //console.log(content);
                                        myJson = { parameters: {} };
                                        if((content != null) && (content.content != null)) { 
                                            myJson = content.content;
                                        }

                                        defaultJson = myJson;
                                        var appJson = JSON.stringify(defaultJson, null, 2);
                                        $('#jsonArea1').val(appJson);
                                        $('#jsonArea2').val(appJson);
                                        printJsonArray();
                                        prepareJobTable();
                                    }
                                }
                            });
                        });
                        break;
                }
            }

            function changeJson() {
                var ans = $('input[name="optradio"]:checked').val();
                switch(ans) {
                    case "old":
                        myJson = defaultJson;                        
                        printJsonArray();
                        break;
                    case "new":
                        var newJson = $('#jsonArea2').val();
                        myJson = JSON.parse(newJson);;
                        printJsonArray();
                        break;
                    default:
                        break;
                }
            }
            function filljsonArea1() {
                var ans = defaultJson;
                var json1 = JSON.stringify(ans, null, 2);
                $('#jsonArea1').val(json1); 
            }
    
        </script>
        <div class="panel panel-default">
            <div class="panel-heading">
                <p><h3>Generic web application </h3></p>
            </div>
        <div class="panel-body">
        <p style="float: left"><span class="glyphicon glyphicon-hand-right"></span> Please remember to sign in to use portlet</p>
        <div align="right">
            <div class="btn-group">
                <button type="button" id="appButton" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                    App Config
                    <span class="caret"></span>
                </button>
                <ul id="dropmenu" class="dropdown-menu" role="menu">
                </ul>
            </div>
            <button type="button" id="jsonButton" class="btn btn-primary" data-toggle="modal" data-target="#jsonConfig" disabled>
                JSON Config
            </button>
        </div>
        <h3>
            <div align="center" id="mainTitle">
                Generic application
            </div>
        </h3>
        <center>
            <button type="button" id="requestButton" class="btn btn-primary btn-lg" onClick="openModal()" disabled>
                Launch request
            </button>
        </center>

        <!-- Submit record table (begin) -->    
        <div id="jobsDiv" data-modify="false"> 
        </div>        
        
        <!-- Submit record table (end) -->
        </div>        
        </div> 
        <div class="panel-footer"></div>

        <!-- Modal (begin) -->
        <div class="modal fade  modal-hidden" id="helloTesterModal" tabindex="-1" role="dialog" aria-labelledby="HelloTester"> 
            <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                <h4 class="modal-title" id="myModalLabel">Submission panel</h4>
              </div>
              <div class="modal-body" id="modalContent" style="max-height: calc(100vh - 210px); overflow-y: auto;">
              </div>
              <div class="modal-footer">
                <center>                
                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                <button type="button" class="btn btn-primary" onClick="submitJob()" id="submitButton">Submit</button>
                </center>
              </div>
            </div>
          </div>
        </div>   
        <!-- Modal (end) -->

        <!-- Confirm Modal Dialog (begin) -->                       
        <div class="modal fade modal-hidden" id="confirmDelete" role="dialog" aria-labelledby="confirmDeleteLabel" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">Delete Parmanently</h4>
              </div>
              <div class="modal-body">
                  <p></p>
              </div>                
                <div id="job_id" class='job_id' data-name='job_id' data-value=''/>
                  <div class="modal-footer">
                  <button type="button" class="btn btn-default" data-dismiss="modal" id="cancelJobDel">Cancel</button>
                  <button type="button" class="btn btn-danger" id="confirmJobDel">Delete</button>
                  </div>
              </div>
            </div>
          </div>
      </div>

        <!-- JSON Config (begin) -->                       
        <div class="modal fade modal-hidden" id="jsonConfig" role="dialog" aria-labelledby="json configuration dialog" aria-hidden="true">
          <div class="modal-dialog">
            <div class="modal-content">
              <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                <h4 class="modal-title">JSON Config</h4>
              </div>
              <div class="modal-body" style="max-height: calc(100vh - 210px); overflow-y: auto;">
                  <form>
                      <div class="radio">
                          <label><input type="radio" name="optradio" value="old" checked>
                              <button type="button" class="btn btn-default btn-xs" data-toggle="collapse" data-target="#jsonTextArea1" onClick="filljsonArea1()">default json</button>
                              object can not be changed
                          </label>
                      </div>
                      <div id="jsonTextArea1" class="collapse">
                          <div class="form-group">
                              <textarea class="form-control" rows="50" id="jsonArea1">
                              </textarea>
                          </div>
                      </div>
                      <div class="radio">
                          <label><input type="radio" name="optradio" value="new">
                              <button type="button" class="btn btn-default btn-xs" data-toggle="collapse" data-target="#jsonTextArea2">new json</button>
                              customizable object
                          </label>
                      </div>
                      <div id=jsonTextArea2 class="collapse">
                          <div class="form-group">
                              <textarea class="form-control" rows="50" id="jsonArea2">
                              </textarea>
                          </div>
                      </div>
                  </form>
              </div>                
              <div class="modal-footer">
                  <center>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" data-dismiss="modal" onClick="changeJson()">OK</button>
                </center>
              </div>
              </div>
            </div>
          </div>
        </div>

          <div class="modal fade modal-hidden" id="information" role="dialog" aria-labelledby="information dialog" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <!-- Modal content-->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Information</h4>
            </div>
            <div class="modal-body">
            </div>
            <div class="modal-footer">
                <center>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </center>
            </div>
            </div>
        </div>
    </div>

      <script>
            Liferay.Service(
                '/iam.token/get-token',
                function(obj) {
                    token = obj;
                    if(obj.token != undefined) {
                        token = obj.token;
                    }
                    welcome();
                    printJsonArray();
                }
            );
        
          var json2 = JSON.stringify(defaultJson, null, 2);
          $('#jsonArea2').val(json2);
      </script>
