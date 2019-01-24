component extends="Consumer" 
{
	
	public QueueConsumer function init(){
		super.init();
		return this;
	}
	
	public string function getDestinationType(){
		return "queue";
	}

}