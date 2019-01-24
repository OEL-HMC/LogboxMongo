component extends="testbox.system.BaseSpec"
{
	
	import "logboxmongo.*";
	import "logbox.system.logging.LogBox";
	import "logbox.system.logging.config.LogBoxConfig";
	
	
	function beforeAll(){
		variables.helper = new cfamq.AMQHelper();
	}
	
	function afterAll(){
		writeOutput( "<br>Unregister" );
		//variables.helper.unregisterPSM();
	}

	function run(){
		
		
		
		describe(
			"cfamq.AMQHelper : initialization",
			function(){
				
				it("Check components load",
					function(){
						
								
						
						expect( variables.helper.getScopeName() ).toBe("application");
						expect( variables.helper.getPubSubManagerName() ).toBe("AMQPubsubManager");
	
						expect( isOBject( variables.helper ) ).toBe(true);
						
						expect( isStruct( variables.helper.getConfig()) ).toBe(true);
						

						expect( structIsEmpty(variables.helper.getconfig()) ).toBe(true);
						
						expect( variables.helper.hasPubSubManager() ).toBe(false);
						
						
					}

				);					

				it(
					"Trying to create a helper with an empty pubsubmanager name throws an error ( CFAMQ.INVALID_PSM_NAME )",
					function(){
						var err = 0;
						try{
							var h1 = new cfamq.AMQHelper('');
						}catch(any e){
							local.err = 1;
						}
						expect( local.err ).toBe(1);
					}
				);

				it(
					"Trying to create a helper with application scope is OK",
					function(){
						var err = 0;
						try{
							var h1 = new cfamq.AMQHelper('name', 'application');
						}catch( CFAMQ.INVALID_SCOPE_NAME e ){
							local.err = 1;
						}
						expect( local.err ).toBe(0);
						expect( local.H1.getScopeName() ).toBe('application');


					}
				);
				it(
					"Trying to create a helper with server scope is OK",
					function(){
						var err = 0;
						try{
							var h1 = new cfamq.AMQHelper('name', 'server');
						}catch( CFAMQ.INVALID_SCOPE_NAME e ){
							local.err = 1;
						}
						expect( local.err ).toBe(0);
						expect( local.H1.getScopeName() ).toBe('server');


					}
				);
				it(
					"Trying to create a helper with request scope is OK",
					function(){
						var err = 0;
						try{
							var h1 = new cfamq.AMQHelper('name', 'request');
						}catch( CFAMQ.INVALID_SCOPE_NAME e ){
							local.err = 1;
						}
						expect( local.err ).toBe(0);
						expect( local.H1.getScopeName() ).toBe('request');


					}
				);

				it(
					"Trying to create a helper with any other scope is NOTOK (throws CFAMQ.INVALID_SCOPE_NAME error) ",
					function(){
						var err = 0;
						try{
							var h1 = new cfamq.AMQHelper('name', '');
						}catch( CFAMQ.INVALID_SCOPE_NAME e ){
							local.err = 1;
						}
						expect( local.err ).toBe(1);


					}
				);
				
			}
		);
		


		describe(
			"cfamq.AMQHelper : PSM creation",
			function(){
				
				it("Check that the initition throws an error (CFAMQ.EMPTY_CONFIG) when configuration is empty.",
					function(){
						var err= 0;
						try{
							variables.helper.createPSM();	
						}catch(CFAMQ.INVALID_CONFIGURATION e){
							err = 1;
						}catch( CFAMQ e  ){
							err = 2;
						}
						catch( any e  ){
							writeDump(e);
							err = 3;
						}
						expect( err ).toBe(1);
						//expect( err ).toBe(1);
					}
					
				);
				
			}
		);

		describe("client conf check : empty struct",
			function (){
				
				var psm = new cfamq.PubSubManager();
				/*
				var result = psm.validateClientConfiguration({});
				
				it("empty conf",
				function(){
					expect( result.valid ).toBeFalse();	
				});
				
				
				it(
					"check missing keys and empty keys",
					function(){
						var requiredFields = psm.getClientConfigurationRequiredKeys();
						var conf = {};
						var nums = 0;
						for( var i =1; i<=arrayLen( requiredFields );  i++  ){
							var keyName = local.requiredFields[ local.i ];
							local.conf.put( local.keyName, '' );
							local.result = psm.validateClientConfiguration( local.conf );
							expect( local.result.valid ).toBeFalse();
							expect( local.result.wrongField ).toBe( local.keyName );
							++nums;
							local.conf[ local.keyName ] = "myvalue_#nums#";
						}		
					}
				);
				
				*/
				
			}
		);

		describe(
			"Configuration validation  (AMQhelper.validateConfiguration(struct)",
			function(){
				
				it(
					"Empty configuration is not allowed",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({});

						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe( "missing connections." );	
					}
				);

				it(
					"Configuration without any 'connections' is not allowed",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'clients': []});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe( "missing connections." );
					}
				);
				
				it(
					"Configuration must have a connections array",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': 0, 'clients':[]});
						expect( res.valid ).toBeFalse();	
						expect( res.message ).toBe( "connections must be a non empty array" );
					}
					
				);
				
				it(
					"Configuration must have a non empty connections array",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [], 'clients': []});
						expect( res.valid ).toBeFalse();	
					}
				);
				
				it(
					"Configuration must have a connections array of structure",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [1], 'clients': [1]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in connections must be a structure");	
					}
				);

				it(
					"Configuration must have a connections array of structure",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{}], 'clients': [1]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in connections must have a 'name' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a connections array of structure",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':''}], 'clients': [1]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in connections must have a 'name' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a connections array of structure containing a non empty string in key 'name'",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok'}, {name:''}], 'clients': [1]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in connections must have a 'name' key holding a non empty string");	
					}
				);

				/*
				*/

				it(
					"Configuration without any 'clients' is not allowed",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe( "missing clients." );
					}
				);
				
				it(
					"Configuration must have a clients array",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: 0}
						);
						expect( res.valid ).toBeFalse();	
						expect( res.message ).toBe( "clients must be a non empty array" );
					}
					
				);
				
				it(
					"Configuration must have a non empty clients array",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: []}
						);
						expect( res.valid ).toBeFalse();	
						expect( res.message ).toBe( "clients must be a non empty array" );
					}
				);
				
				it(
					"Configuration must have a clients array of structure",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ 0 ]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must be a structure");	
					}
				);

				it(
					"Configuration must have a clients array of structure having a 'name' key",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ {} ]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'name' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a clients array of structure with non empty value for 'connectionName' key",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ { 'name': 'ok1' } ]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'connectionName' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a clients array of structure with non empty value for 'destinationType' key",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ { 'name': 'ok1', connectionName='ok1' } ]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'destinationType' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a clients array of structure with non empty value for 'connectionName' key",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], 
							clients: [ { 'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic' },{ 'name': 'ok1', 'connectionName': '' } ]
							}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'connectionName' key holding a non empty string");	
					}
				);


				it(
					"Configuration must have a clients array of structure with non empty value for 'name' key",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration(
							{'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ { 'name': '' } ]}
						);
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'name' key holding a non empty string");	
					}
				);

				it(
					"Configuration must have a clients array of structure containing a non empty string in key 'name'",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ 
							{ 'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic' }, {'name': ''} ]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("Each item in clients must have a 'name' key holding a non empty string");	
					}
				);

				

				it(
					"Configuration connections names must be unique",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ 
							{ 'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic' }, {'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic' } ]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("clients names must be unique.");	
					}
				);
				it(
					"Configuration clients names must be unique",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok1'}], clients: [ 
							{ 'name': 'ok1' }, {'name': 'ok2'} ]});
							expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("connections names must be unique.");	
					}
				);

				it(
					"Configuration clients names must be unique",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok1'}], clients: [ 
							{ 'name': 'ok1' }, {'name': 'ok2'} ]});
							expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("connections names must be unique.");	
					}
				);

				it(
					"Configuration NOT OK : connectionName must be the name of a configured connection",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ 
							{ 'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic' }, {'name': 'ok2', 'connectionName': 'ok1notexisst', destinationType:'topic'} ]});
						expect( res.valid ).toBeFalse();
						expect( res.message ).toBe("connectionName ok1notexisst does not exist in configured connections.");	
					}
				);

				it(
					"Configuration OK",
					function(){
						var h1 = new cfamq.AMQHelper();
						var res = h1.validateConfiguration({'connections': [{'name':'ok1'}, {name:'ok2'}], clients: [ 
							{ 'name': 'ok1', 'connectionName': 'ok1', destinationType:'tropic' }, {'name': 'ok2', 'connectionName': 'ok1', destinationType:'topic'} ]});
						expect( res.valid ).toBeTrue();
						//expect( res.message ).toBe("Each item in clients must have a 'name' key holding a non empty string");	
					}
				);

				it(
					"createPSM",
					function(){
						var h1 = new cfamq.AMQHelper().setConfig(
						{
						'connections': [{'name':'ok1'}, {name:'ok2'}], 
						'clients': [
							{'name': 'ok2', 'connectionName': 'ok2', destinationType:'topic', 'type': 'consumer', 'destinationName': 'HELLO_WORLD_TOPIC', listener:{ "fullName": "cfamq.MessageListener" }}, 
							{ 'name': 'ok1', 'connectionName': 'ok1', destinationType:'topic', 'type': 'publisher', 'destinationName': 'HELLO_WORLD_TOPIC' }
							]
						}
						);
						
						

						var psm = h1.createPSM();
						
						psm.send( 'ok1', 'hello World' );
							
					}
				);

			}
		);

		/*
		describe(
			"Check configuration errors",
			function(){
				it(
					"Config with empty array of connections",
					function(){
						var h1 = new cfamq.AMQHelper();
						h1.setConfig( { connections:[], clients:[] } );
						local.err = 0;
						try{
							h1.createPSM();
						}catch( CFAMQ.INVALID_CONFIG.CONNECTIONS ){
							local.err = 1;
						}
						expect( local.err ).toBe(1);
					}
				);
			}
			
			
		);
		*/
	}
	
}