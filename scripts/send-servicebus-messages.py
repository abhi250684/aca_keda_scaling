import sys
from azure.identity import AzureCliCredential
from azure.servicebus import ServiceBusClient, ServiceBusMessage
ns, queue, count = sys.argv[1], sys.argv[2], int(sys.argv[3])
with ServiceBusClient(f"{ns}.servicebus.windows.net", AzureCliCredential()) as client:
    with client.get_queue_sender(queue_name=queue) as sender:
        for i in range(count): sender.send_messages(ServiceBusMessage(f"message-{i+1}"))
