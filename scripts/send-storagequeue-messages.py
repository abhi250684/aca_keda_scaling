import sys
from azure.identity import AzureCliCredential
from azure.storage.queue import QueueClient
account, queue, count = sys.argv[1], sys.argv[2], int(sys.argv[3])
client = QueueClient(account_url=f"https://{account}.queue.core.windows.net", queue_name=queue, credential=AzureCliCredential())
for i in range(count): client.send_message(f"message-{i+1}")
