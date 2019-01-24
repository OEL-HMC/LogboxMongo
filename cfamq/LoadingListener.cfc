component accessors="false" {
	
	property name="logger";
	
	import "activemq.helpers.*";
	import "model.loading.adp.*";
	
	public LoadingListener function init(){
		return this;
	}
	
	public LoadingListener function setLogger( required any logger ){
		variables.logger = arguments.logger;
		return this;
	}
	
	private  function getLogger(){
		return variables.logger ?: application.consoleLogger;
	}
	
	
	public void function handleNotification( required string name, any data ){
	}
	

	private void function spreadTechnicalProperties( required any data )
	hint="Copy conf from application to server scope"
	{
		getLogger().info( '*** Setting technical props in application scope') ;
		application.props = arguments.data;
		 var keysToCopy = listAppend('','PUBLICATION_PATH,PUBLICATION_PATH_ARCHIVE,PUBLICATION_PATH_ERROR,AMQ_BROKER_URL,AMQ_TOPIC_PUBLICATION_IN,AMQ_TOPIC_PUBLICATION_OUT,AMQ_PUBLICATION_PATH' );
		 keysToCopy = listAppend(keysToCopy,'PUBLICATION_PATH_OUTPUT_MASK,LOG_FOLDER,LOG_LEVEL,LOG_MAXSIZE,LOG_ROTATE,LOG_MAXARCHIVES');
		 getLogger().info( '*** Setting technical props in server scope') ;
		 for( var key in listToArray( local.keysToCopy ) ){
		 	if( (application.props[ key ] ?: '') != '' ){
		 		server[ key ] = application.props[ key ];
		 	}
		 }
	}
	

	private void function loadActiveMQ(){
		
		//called after spreadTechnicalProperties 
		var helper = new AMQHelper( 'AMQPubsubManager' );
		
		var pubListener = new PublicationTopicListener();
		pubListener.setPublicationLoader(
			new model.loading.adp.PublicationLoader()
				.setDownloadFolder( application.props.PUBLICATION_PATH )
				.setLogger( getLogger() )
				.setPublicationUrl(Application.props.AMQ_PUBLICATION_PATH)
		);
		local.pubListener.setLogger( getLogger() );
		
		
		var publisherName = 'eqs' & '-' & Application.props.AMQ_TOPIC_PUBLICATION_OUT & '-publisher';
		var consumerName = 'eqs' & '-' & Application.props.AMQ_TOPIC_PUBLICATION_IN & '-consumer';
		
		
		
	
		
		var psm = helper.setConfig(
			{ 
							"connections":[ {'name': 'default', 'brokerURL': Application.props.AMQ_BROKER_URL } ],
							"clients":[
								{
									'name': local.consumerName,
									'type': 'consumer',
									'destinationType': 'topic',
									'destinationName': Application.props.AMQ_TOPIC_PUBLICATION_IN,
									'durable': true,
									'listener': local.pubListener,
									'connectionName': 'default'
								},
								{
									'name': local.publisherName,
									'type': 'publisher',
									'destinationType': 'topic',
									'destinationName': Application.props.AMQ_TOPIC_PUBLICATION_IN,
									'durable': true,
									'connectionName': 'default'
								},
								{
									'name': 'queue-sender',
									'type': 'publisher',
									'destinationType': 'queue',
									'destinationName': 'eqs-queue-test-2019',
									'durable': true,
									'connectionName': 'default'
								},
								{
									'name': 'topic-consumer-test1',
									'type': 'consumer',
									'destinationType': 'topic',
									'destinationName': 'eqs-consumer1-test-2019',
									'durable': true,
									'connectionName': 'default',
									'listener': {
										'fullName': 'activemq.proxy.MessageListener',
										'initArgs': { name="Olivier" }
									}
								}
								,
								{
									'name': 'queue-consumer-test2',
									'type': 'consumer',
									'destinationType': 'queue',
									'destinationName': 'eqs-consumer2-test-2019',
									'durable': true,
									'connectionName': 'default',
									'listener': {
										'fullName': 'activemq.proxy.MessageListener',
										'initArgs': { name="Olivier" }
									}
								}
							]
							
			}
		).createPSM();
		
		local.pubListener.setPSM( local.psm );
		local.pubListener.setPublisherName( local.publisherName );
		
		
	}
	
}