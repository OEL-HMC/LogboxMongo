component extends="testbox.system.BaseSpec"
{
	
	import "logboxmongo.*";
	
	function run(){
		describe(
			"basic tests",
			function(){
				it(
					"create an appender",
					function(){
						var app = new MongoAppender("test");
						expect( getMetadata(local.app).fullname ).toBe( "logboxmongo.MongoAppender" ); 
					}
				);
				it(
					"create a config",
					function(){
						var app = new samples.SimpleConfig();
						expect( getMetadata(local.app).fullname ).toBe( "logboxmongo.samples.SimpleConfig" );
						
						var err = false;
						try{
							local.app.configure();
						}catch( any e ){
							local.err = true;
							writeDump(e);
						}
						expect( local.err ).toBe( false );
						 
					}
				);
			}
		);
	}
	
}