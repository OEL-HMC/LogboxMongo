component extends="testbox.system.BaseSpec"
{
	
	import "logboxmongo.*";
	import "logbox.system.logging.LogBox";
	import "logbox.system.logging.config.LogBoxConfig";
	
	function run(){
		describe(
			"basic tests",
			function(){
				
				/*
				it(
					"create an appender",
					function(){
						var app = new MongoAppender("test");
						expect( getMetadata(local.app).fullname ).toBe( "#request.logboxmongopath#MongoAppender" ); 
					}
				);
				it(
					"create a config",
					function(){
						var app = new samples.SimpleConfig();
						expect( getMetadata(local.app).fullname ).toBe( "#request.logboxmongopath#samples.SimpleConfig" );
						
						var err = false;
						try{
							local.app.configure();
						}catch( any e ){
							local.err = true;
						}
						expect( local.err ).toBe( false ); 
					}
				);
				
				it(
					"Check loading an appender with config",
					function(){
						var app = new MongoAppender("test", 
							{
								 "target":{ "database": "dbname", "collection": "collName", "host": "127.0.0.1", "port": "27017" } 
							}
						);
						expect( isStruct(app.getTargetConfiguration()) ).toBe(true);
						expect( app.getTargetConfiguration().host ).toBe("127.0.0.1");
						expect( app.getTargetConfiguration().port ).toBe("27017");
						expect( app.getTargetConfiguration().port.getClass().getName() ).toBe("java.lang.Integer");
						
					}
				);
				
				
				
				it(
					"Check loading an appender with NO config",
					function(){
						var app = new MongoAppender("test");
						expect( isStruct(app.getTargetConfiguration()) ).toBe(true);
						expect( app.getTargetConfiguration().host ).toBe("127.0.0.1");
						expect( app.getTargetConfiguration().port ).toBe("27017");
						expect( app.getTargetConfiguration().port.getClass().getName() ).toBe("java.lang.Integer");
					}
				);
				*/
				
				
				it("Create a logbox with sample config",
				function(){
					var logger = new LogBox( new LogBoxConfig( CFCConfigPath='samples.SimpleConfig' ) );
					logger.getLogger('GENERAL').fatal('Fatal Hello world !!!');
					logger.getLogger('GENERAL').error('warn Hello world !!!');
					logger.getLogger('GENERAL').warn('warn Hello world !!!');
					logger.getLogger('GENERAL').info('info Hello world !!!');
					logger.getLogger('GENERAL').debug('debug Hello world !!!');
				}
					
				);
				
			}
		);
	}
	
}