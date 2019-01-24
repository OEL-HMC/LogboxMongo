component accessors="true" hint="Parent of all consumers and publishers"
{
    property name="connectionID" type="string" hint="clientID from ActiveMQConnection";
    property name="amqSessionId" type="string" hint="Session id that created that client" ;
    property name="name" type="string" hint="Stores the client name, useful in durable consumers";
    property name="createdAt";

    public AMQClient function init(){
        variables.createdAt = now();
        return this;
    }

    public string function getDestinationType()
    hint="Each subcomponent must say if they use topics or queues"
    {
        throw( message="you must override that function Must be topic or queue" );
    }

    public string function getClientType()
    hint="Each subcomponent must say if they are consumers or publishers"
    {
        throw( message="you must override that function Must be publisher or consumer" );
    }

    public AMQClient function setName( required string name ){
        variables.name = arguments.name;
        return this;
    }

    public AMQClient function setConnectionId( required string connectionID ){
        variables.connectionId = arguments.connectionID;
        return this;
    }

    public AMQClient function setAmqSessionId( required string sessionId ){
        variables.amqSessionId = arguments.sessionId;
    }

    public struct function toStruct(){
        return {
            "clientID": getConnectionId(),
            "name": getName(),
            "type": getDestinationType(),
            "createdAt": getCreatedAt()
        }
    }

}