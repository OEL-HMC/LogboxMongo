component extends="testbox.system.BaseSpec"
{
	
	import "logboxmongo.*";
	import "logbox.system.logging.LogBox";
	import "logbox.system.logging.config.LogBoxConfig";
	
	function beforeAll(){
		variables.connection = createObject( "java", "com.mongodb.MongoClient" ).init();
		variables.collection = variables.connection.getDatabase("mongologbox").getCollection("mongologbox_collection");
	}
	function afterAll(){
		variables.connection.dropDatabase( "mongologbox" );
		variables.connection.close();
	}
	
	function createFilter( required numeric severity, required string message ){
		return createObject( "java", "org.bson.Document" ).init(
			{
				"severity": javacast('int', arguments.severity),
				"message": arguments.message
			}
		);
	}
	
	function run(){
		describe(
			"basic tests",
			function(){
				
				it("Create a logbox with sample config",
					function(){
						var logger = new LogBox( new LogBoxConfig( CFCConfigPath='samples.SimpleConfig' ) );
						var fatalMessage = "Hello world !!!#createUUID()#";
						var errorMessage = "Hello world !!!#createUUID()#";
						var warnMessage = "Hello world !!!#createUUID()#";
						var infoMessage = "Hello world !!!#createUUID()#";
						var debugMessage = "Hello world !!!#createUUID()#";
						
						logger.getLogger('GENERAL').fatal(fatalMessage);
						expect( collection.count(createFilter(0,fatalMessage)) ).toBe(1);
						
						logger.getLogger('GENERAL').error(errorMessage);
						expect( collection.count(createFilter(1,errorMessage)) ).toBe(1);
						
						logger.getLogger('GENERAL').warn(warnMessage);
						expect( collection.count(createFilter(2,warnMessage)) ).toBe(1);
						
						logger.getLogger('GENERAL').info(infoMessage);
						expect( collection.count(createFilter(3,infoMessage)) ).toBe(1);
						
						logger.getLogger('GENERAL').debug(debugMessage);
						expect( collection.count(createFilter(4,debugMessage)) ).toBe(1);
					}
				);
				
			}
		);
	}
	
}