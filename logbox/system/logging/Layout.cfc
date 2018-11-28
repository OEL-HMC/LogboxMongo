<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	3/13/2009
Description :
	This is a base layout object that will help you create custom
	layout's for messages in appenders
----------------------------------------------------------------------->
<cfcomponent output="false" hint="This is a base custom layout for a message in an appender.">

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<cfscript>
		// The log levels enum as a public property
		this.logLevels = createObject("component","logbox.system.logging.LogLevels");
		// A line Sep Constant, man, wish we had final in CF.
		this.LINE_SEP  = chr(13) & chr(10);
	</cfscript>

	<!--- Init --->
	<cffunction name="init" access="public" returntype="Layout" hint="Constructor" output="false">
		<cfargument name="appender" type="any" required="true" default="" hint="The appender linked to (logbox.system.logging.AbstractAppender)" colddoc:generic="logbox.system.logging.AbstractAppender"/>
		<cfscript>

			// The appender we are linked to.
			instance.appender = arguments.appender;

			// Return
			return this;
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------>

	<!--- format --->
	<cffunction name="format" output="false" access="public" returntype="string" hint="Format a logging event message into your own format">
		<cfargument name="logEvent" type="any"   required="true"   hint="The logging event to use to create a message (logbox.system.logging.LogEvent)" colddoc:generic="logbox.system.logging.LogEvent">
		<cfscript>
			var loge = arguments.logEvent;
			var timestamp = loge.getTimestamp();
			var message = loge.getMessage();
			var entry = "ce test de custom layout fonctionne";

			// Does file still exist?
			if( NOT fileExists( instance.appender.GETLOGFULLPATH() ) ){
				ensureDefaultLogDirectory();
				initLogLocation();
			}

			// Cleanup main message
			message = replace(message,'"','""',"all");
			message = replace(message,"#chr(13)##chr(10)#",'  ',"all");
			message = replace(message,chr(13),'  ',"all");
			if( len(loge.getExtraInfoAsString()) ){
				message = message & " " & loge.getExtraInfoAsString();
			}
			// Entry string
			entry = '"#instance.appender.severityToString(logEvent.getSeverity())#","#instance.appender.getname()#","#dateformat(timestamp,"MM/DD/YYYY")#","#timeformat(timestamp,"HH:MM:SS")#","#loge.getCategory()#","#message#"';

			// Setup the real entry
			append(entry);
		</cfscript>
	</cffunction>

</cfcomponent>