component extends="AMQClient" accessors="true" hint="Parent of all topic consumers and queue consumers"
{
	property name="consumer";
	
	public Consumer function init(){
		super.init();
		return this;
	}
	
	public Consumer function setConsumer( required any consumer ){
		variables.consumer = arguments.consumer;
		return this;
	}
	
	public string function getClientType(){
		return "consumer";
	}

}