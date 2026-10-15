# Shared model request queue

Date: 2026-10-10

The user requested queued model requests.
Forest cards within one search already used sequential model requests.
Separate browser searches could still send concurrent requests.

`Model::RequestQueue::SHARED` now gives all forest card collections one FIFO queue in the server process.
Only one queued model request runs at a time.
Each request starts its 89-second deadline after it gets its turn.
Failures and cancelled waiting requests release the queue.
The queue does not change or validate model responses.

Implementation: `lib/model/request_queue.rb` and `lib/card/collection.rb`.
