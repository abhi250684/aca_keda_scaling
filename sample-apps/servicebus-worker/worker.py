import os, time
from azure.identity import DefaultAzureCredential
from azure.servicebus import ServiceBusClient
namespace = os.environ['SERVICEBUS_NAMESPACE']
queue = os.environ['SERVICEBUS_QUEUE']
credential = DefaultAzureCredential()
while True:
    try:
        with ServiceBusClient(namespace, credential) as client:
            with client.get_queue_receiver(queue_name=queue, max_wait_time=20) as receiver:
                for message in receiver:
                    print(f"Service Bus message: {message}", flush=True)
                    receiver.complete_message(message)
    except Exception as exc:
        print(f"worker error: {exc}", flush=True)
        time.sleep(5)
