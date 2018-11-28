/**
* Engine dev LogBox configuration object
**/
component{

	/**
	* Configure LogBox
	*/
	function configure(){
		logBox = {
			// Define Appenders
			appenders = {
				MyLogFile = {
	                class="logbox.system.logging.appenders.AsyncRollingFileAppender",
	                properties={
	                    filePath = server.LOG_FOLDER,
	                    autoExpand=false,
	                    fileMaxArchives=10,
	                    fileMaxSize=1000, //in KB
	                    fileName="quotation-engine",
	                }
	            }/*,
				MyDebugFile = {
	                class="logbox.system.logging.appenders.RollingFileAppender",
	                properties={
	                    filePath = application.fileLog,
	                    autoExpand=false,
	                    fileMaxArchives=1,
	                    fileMaxSize=300,
	                    async=true,
	                    fileName="debug",
	                }
	            }*/
	            /*,
				MyErrorFile = {
	                class="logbox.system.logging.appenders.RollingFileAppender",
	                properties={
	                    filePath = application.fileLog,
	                    autoExpand=false,
	                    fileMaxArchives=1,
	                    fileMaxSize=3000,
	                    async=true,
	                    fileName="error",
	                }
	            }*/
	            /*,
				Console = {
					class="logbox.system.logging.appenders.ConsoleAppender"
				}*/
			},
			// Root Logger
			root = {levelMin="fatal", levelMax="debug", appenders='MyLogFile'},
 			// Categories
			categories = {
				"QE.LOG" = {levelMin="FATAL", levelMax=server.LOG_LEVEL, appenders="MyLogFile"}
			}
			/*categories = {*/
				/*"engine.log" = {levelMin="FATAL", levelMax="DEBUG", appenders="MyInfoFile,Console"},*/
				/*"engine.log.debug" = {levelMin="DEBUG", levelMax="DEBUG", appenders="MyDebugFile"},*/
				/*"engine.log.error" = {levelMin="fatal", levelMax="error", appenders="MyLogFile"}
			}/*,
			debug  = ["engine.log.debug"],*/
			/*info = ["engine.log"],
			warn = ["engine.log"],
			error = ["engine.log", "engine.log.error"],
			fatal = ["engine.log", "engine.log.error"]
			off = ["engine.log", "engine.log.error"]*/
		};
	}

}
