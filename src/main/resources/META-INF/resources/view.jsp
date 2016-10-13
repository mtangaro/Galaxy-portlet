<%@ include file="/init.jsp" %>

        <script type="text/javascript">
            /*
             * All the web app needs to configure are the following
             */
            var paramJson = { parameters: {} };
            var myJson = <%= defaultArray %> ;
            var defaultJson = myJson;
            var jsonArr; 
            var token = null;
            var jobLimit = 5;
            var Jdiv = 0;
            var LI="LI_0";
            
            var webapp_settings = {
                apiserver_url: ''
               ,apiserver_path : '/apis'
               ,apiserver_ver  : 'v1.0'
               ,app_id         : 103               
            };
            /* Settings for sgw.indigo-datacloud.eu
            var webapp_settings = {
                apiserver_proto: 'https'
               ,apiserver_host : 'sgw.indigo-datacloud.eu'
               ,apiserver_port : '443'
               ,apiserver_path : '/apis'
               ,apiserver_ver  : 'v1.0'
               ,username       : 'brunor'
               ,app_id         : 1
            };
            */
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
            Liferay.Service(
            		  '/iam.token/get-token',
                        function(obj) {
            		    token = obj;
                        //console.log(obj);
                        prepareJobTable();                 // Fills the job table
            		  }
            );
            function printDefault() {
                out = '<p><b>job identifier </b></br>';
                out += '<input type="text" maxlength="50" id="jobDescription" class="form-control"></p>';
                document.getElementById("modalContent").innerHTML = out;
            }
            function printJsonArray() {
                jsonArr = myJson.parameters;
                var i;
                var k;
                printDefault();
                var out = '<div id="params-modal">';
                for(i = 0; i < jsonArr.length; i++) {
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
                            out += '<input type="text" maxlength="50" id="param_'+jsonArr[i].name
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
                }
                out += '</div>';
                var myDiv = document.getElementById("modalContent");
                myDiv.innerHTML = myDiv.innerHTML + out;
            }
            function getParams() {
                jsonArr = myJson.parameters;
                paramJson = { parameters: {} };
                for(var i=0; i<jsonArr.length; i++) {
                    switch(jsonArr[i].type) {
                        case "radio":
                            var out = $('input[name='+jsonArr[i].name+']:checked').val();
                            paramJson.parameters[jsonArr[i].name] = out;
                            break;
                        default:
                            var out = $('#param_'+jsonArr[i].name).val();
                            if(jsonArr[i].name == "number_cpus") {
                                out = parseInt(out);
                            }
                            paramJson.parameters[jsonArr[i].name] = out;
                    }
                }
                callServeResource();
            }
            function callServeResource() {
                var myData = {<portlet:namespace />json: JSON.stringify(paramJson)};
                AUI().use('aui-io-request', function(A){
                    A.io.request('<%=resourceURL.toString()%>', {
                    dataType: 'json',
                    method: 'post',
                    data: myData
                    });
                });
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
                var ans = <%= defaultArray %>;
                var json1 = JSON.stringify(ans, null, 2);
                $('#jsonArea1').val(json1); 
            }
    
        </script>
        <div class="panel panel-default">
            <div class="panel-heading">
                <p style="float: left"><h3>Galaxy web application </h3></p>
                <p style="float: right">
                    <button type="button" class="btn btn-default btn-sm" data-toggle="modal" data-target="#jsonConfig">
                    JSON Config
                    </button>
                </p>
            </div>
        <div class="panel-body">
        <p><span class="glyphicon glyphicon-hand-right"></span> Please remember to sign in to use portlet</p>
        <button type="button" class="btn btn-primary btn-lg" onClick="openModal()">
            Launch Galaxy request
        </button>

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
                <h4 class="modal-title" id="myModalLabel">Galaxy submission panel</h4>
              </div>
              <div class="modal-body" id="modalContent" style="max-height: calc(100vh - 210px); overflow-y: auto;">
              </div>
              <script>
                  printJsonArray();
              </script>
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
{
    "parameters": [
    {
    "name":"test",
    "type":"text",
    "value":"value"
    }
    ]
}
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
