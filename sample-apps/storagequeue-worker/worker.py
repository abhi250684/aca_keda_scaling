import os, time
from azure.identity import DefaultAzureCredential
from azure.storage.queue import QueueClient
account_url = os.environ['STORAGE_ACCOUNT_URL']
queue = os.environ['STORAGE_QUEUE']
credential = DefaultAzureCredential()
client = QueueClient(account_url=account_url, queue_name=queue, credential=credential)
while True:
    try:
        found = False
        for message in client.receive_messages(messages_per_page=16, visibility_timeout=60):
            found = True
            print(f"Storage Queue message: {message.content}", flush=True)
            client.delete_message(message)
        if not found: time.sleep(5)
    except Exception as exc:
        print(f"worker error: {exc}", flush=True)
        time.sleep(5)
