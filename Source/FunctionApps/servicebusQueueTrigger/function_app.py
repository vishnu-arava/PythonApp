import azure.functions as func
import logging
import json
import os
from azure.servicebus import ServiceBusClient, ServiceBusMessage

app = func.FunctionApp()

def send_message_to_topic(messagebody, topic_name):
    connection_str = os.getenv("weatherappsbvc_SERVICEBUS")
    servicebus_client = ServiceBusClient.from_connection_string(conn_str=connection_str, logging_enable=True)
    sender = servicebus_client.get_topic_sender(topic_name=topic_name)
    message = ServiceBusMessage(messagebody)
    with sender:
        sender.send_messages(message)
        logging.info(f"Message sent to topic {topic_name}: {messagebody}")
    servicebus_client.close()

@app.function_name("Servicebus_queue_trigger")
@app.service_bus_queue_trigger(arg_name="azservicebus", queue_name="weatherappqueue", connection="weatherappsbvc_SERVICEBUS")
def servicebus_trigger(azservicebus: func.ServiceBusMessage):
    # logging.info('Python ServiceBus Queue trigger processed a message: %s', azservicebus.get_body().decode('utf-8'))
    messagebody = json.loads(azservicebus.get_body().decode('utf-8'))
    logging.info("Received message: %s", messagebody)
    messagebody_str = json.dumps(messagebody)
    if messagebody.get('feature') == "weather search":
        # logging.info("The given message is for the weather search topic")
        send_message_to_topic(messagebody_str, 'weathersearch')
    elif messagebody.get('feature') == "weather report":
        # logging.info("The given message is for the weather report topic")
        send_message_to_topic(messagebody_str, 'weatherreport')
    elif messagebody.get('feature') == "fireforest":
        send_message_to_topic(messagebody_str, 'fireforest')