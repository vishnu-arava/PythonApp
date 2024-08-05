import azure.functions as func
import logging

app = func.FunctionApp()

@app.service_bus_queue_trigger(arg_name="azservicebus", queue_name="weatherappqueue",connection="weatherappsbdev_SERVICEBUS") 
def servicebus_queue_trigger(azservicebus: func.ServiceBusMessage):
    logging.info('Python ServiceBus Queue trigger processed a message: %s',azservicebus.get_body().decode('utf-8'))
    print('Python ServiceBus Queue trigger processed a message: %s',azservicebus.get_body().decode('utf-8'))